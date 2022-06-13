import XCTest

@testable import CitySearch

final class IndexedCitiesRepositoryDataTests: XCTestCase {
    
    typealias Index = CaseInsensitiveTextIndex<TrieTextIndex<UInt32>>
    
    typealias Subject = IndexedCitiesRepository<Index>

    private var fileURL: URL!
    private var filePath: String!
    
    override func setUp() {
        let directoryURLs = FileManager.default.urls(
            for: .cachesDirectory,
               in: .userDomainMask
        )
        let filename = String(describing: TextIndexEncoderDecoderTests.self) + UUID().uuidString
        fileURL = directoryURLs
            .first!
            .appendingPathComponent(filename, isDirectory: false)
            .appendingPathExtension("bin")
        filePath = fileURL.path
        print("Path:", filePath!)
    }
    
    func testDecodedSearch_shouldReturnNothing_givenZeroValues() async throws {
        let surrogate = makeSubject(cities: [])
        let data = surrogate.data()
        let subject = try Subject(data: data)
        let controlResults = await surrogate.searchByName(prefix: "")
        let actualResults = await subject.searchByName(prefix: "")
        XCTAssertEqual(Array(controlResults), [])
        XCTAssertEqual(Array(actualResults), [])
    }
    
    func testDecodedSearch_shouldReturnCity_givenOneCharacter() async throws {
        let city = City(
            _id: 23,
            country: "ZA",
            name: "a",
            coord: Coordinate(lon: 0, lat: 0)
        )
        let surrogate = makeSubject(cities: [city])
        let data = surrogate.data()
        let subject = try Subject(data: data)
        let controlResults = await surrogate.searchByName(prefix: "a")
        let actualResults = await subject.searchByName(prefix: "a")
        XCTAssertEqual(Array(controlResults), [city])
        XCTAssertEqual(Array(actualResults), [city])
    }
    
    func testDecodedSearch_shouldReturnCity_givenOneValue() async throws {
        let city = City(
            _id: 23,
            country: "ZA",
            name: "aardvark",
            coord: Coordinate(lon: 0, lat: 0)
        )
        let surrogate = makeSubject(cities: [city])
        let data = surrogate.data()
        let subject = try Subject(data: data)
        let controlResults = await surrogate.searchByName(prefix: "aardvark")
        let actualResults = await subject.searchByName(prefix: "aardvark")
        XCTAssertEqual(Array(controlResults), [city])
        XCTAssertEqual(Array(actualResults), [city])
    }
    
    
    func testDecodedSearch_shouldReturnCitiess_givenMultipleValues() async throws {
        let city0 = City(
            _id: 23,
            country: "ZA",
            name: "aardvark",
            coord: Coordinate(lon: 0, lat: 0)
        )
        let city1 = City(
            _id: 17,
            country: "ZA",
            name: "barcelona",
            coord: Coordinate(lon: 0, lat: 0)
        )
        let city2 = City(
            _id: 19,
            country: "ZA",
            name: "berlin",
            coord: Coordinate(lon: 0, lat: 0)
        )
        let surrogate = makeSubject(cities: [city0, city1, city2])
        let data = surrogate.data()
        let subject = try Subject(data: data)
        let controlResults = await surrogate.searchByName(prefix: "b")
        let actualResults = await subject.searchByName(prefix: "b")
        XCTAssertEqual(Array(controlResults), [city1, city2])
        XCTAssertEqual(Array(actualResults), [city1, city2])
    }

//    func testJSONPerformance() throws {
//        measure(metrics: defaultMetrics()) {
//            let subject = try! loadCityData()
//            XCTAssertEqual(Array(subject.search(prefix: "Witbank").), [35999])
//            XCTAssertEqual(Array(subject.search(prefix: "New York").iterator), [1340, 4818, 4846, 203003, 204085])
//        }
//    }
    
//    func testDataCodec_correctness() async throws {
//        let index = try loadCityData()
//        try index.write(to: fileURL)
//        let subject = try! Subject(fileURL: fileURL)
//        let results = await subject.searchByName(prefix: "Witbank")
//        XCTAssertEqual(Array(results)[0]._id, 35999)
//    }

//    func testDataCodec_performance() async throws {
//        let index = try loadCityData()
//        try index.write(to: fileURL)
//        measure(metrics: defaultMetrics()) {
//            let _ = try! Subject(fileURL: fileURL)
//        }
//    }
    
    //    func testInitPerformance_fromFile() throws {
    //        let fileURL = Bundle.main.url(forResource: "cities.json", withExtension: "z")!
    //
    //        let subject = try CaseInsensitiveTextIndex<TrieTextIndex>(fileURL: fileURL)
    //        XCTAssertEqual(Array(subject.search(prefix: "Witbank").iterator), [35999])
    //        XCTAssertEqual(Array(subject.search(prefix: "New York").iterator), [1340, 4818, 4846, 203003, 204085])
    //    }
    
    ///
    ///
    ///
    private func loadCityData() throws -> Subject {
        let url = Bundle.main.url(forResource: "cities", withExtension: "json")!
        let data = try Data(contentsOf: url, options: [.uncached])
        let decoder = JSONDecoder()
        let cities = try decoder.decode([City].self, from: data)
        return makeSubject(cities: cities)
    }
    
    
    private func makeSubject(cities: [City]) -> Subject {
        var nameIndex = CaseInsensitiveTextIndex(TrieTextIndex<UInt32>())
        cities.enumerated().forEach { index, city in
            nameIndex.insert(key: city.name, value: UInt32(index))
        }
        return Subject(
            cities: cities,
            nameIndex: nameIndex
        )
    }
}


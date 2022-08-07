import XCTest

@testable import CitySearch

final class IndexedCitiesRepositoryDataCodablePerformanceTests: XCTestCase {
    
    typealias Index = CaseInsensitiveTextIndex<TrieTextIndex<UInt32>>
    
    typealias Subject = IndexedCitiesRepository<Index>

    func testJSONPerformance() async throws {
        let data = try loadJSONData()
        let subject = try decodeJSONData(data: data)
        let results = await subject.searchByName(prefix: "Witbank")
        XCTAssertEqual(Array(results)[0].name, "Witbank")
        measure(metrics: defaultMetrics()) {
            let _ = try! decodeJSONData(data: data)
        }
    }

    func testDataCodable_performance() async throws {
        let jsonData = try loadJSONData()
        let surrogate = try decodeJSONData(data: jsonData)
        let data = surrogate.data()
        let subject = try! Subject(data: data)
        let results = await subject.searchByName(prefix: "Witbank")
        XCTAssertEqual(Array(results)[0].name, "Witbank")
        measure(metrics: defaultMetrics()) {
            let _ = try! Subject(data: data)
        }
    }
    
    func testDataCodableFile_performance() async throws {
        let fileURL = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("Cities-" + UUID().uuidString)
            .appendingPathExtension("z")
        print(fileURL)
        let jsonData = try loadJSONData()
        let surrogate = try decodeJSONData(data: jsonData)
        try surrogate.write(to: fileURL)
        let attachment = XCTAttachment(contentsOfFile: fileURL)
        attachment.lifetime = .keepAlways
        add(attachment)
        let subject = try Subject(fileURL: fileURL)
        let results = await subject.searchByName(prefix: "Witbank")
        XCTAssertEqual(Array(results)[0].name, "Witbank")
        measure(metrics: defaultMetrics()) {
            _ = try! Subject(fileURL: fileURL)
        }
    }

    ///
    ///
    ///
    private func loadJSONData() throws -> Data {
        let url = Bundle.main.url(forResource: "cities", withExtension: "json")!
        let data = try Data(contentsOf: url, options: [.uncached])
        return data
    }
    
    ///
    ///
    ///
    private func decodeJSONData(data: Data) throws -> Subject {
        let decoder = JSONDecoder()
        let cities = try decoder.decode([City].self, from: data)
        return makeSubject(cities: cities)
    }    
    
    ///
    ///
    ///
    private func makeSubject(cities: [City]) -> Subject {
        var nameIndex = CaseInsensitiveTextIndex(TrieTextIndex<UInt32>())
        cities.enumerated().forEach { index, city in
            let key = city.name + ", " + city.country
            return nameIndex.insert(key: key, value: UInt32(index))
        }
        return Subject(
            cities: cities,
            nameIndex: nameIndex
        )
    }
}


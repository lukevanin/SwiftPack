import XCTest

@testable import CitySearch

final class IndexedCitiesRepositoryDataCodableTests: XCTestCase {
    
    typealias Index = CaseInsensitiveTextIndex<TrieTextIndex<UInt32>>
    
    typealias Subject = IndexedCitiesRepository<Index>

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


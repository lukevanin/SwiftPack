import XCTest

@testable import CitySearch

final class CitiesRepositoryTests: XCTestCase {
    
    struct MockTextIndex: TextIndex {
        
        var mockInsert: ((_ key: String, _ value: Int) -> Void)!
        var mockSearch: ((_ prefix: String) -> [Int])!
        
        func insert(key: String, value: Int) {
            mockInsert(key, value)
        }
        
        func search<S>(prefix: S) -> AnyIterator<Int> where S : StringProtocol {
            AnyIterator(mockSearch(String(prefix)).makeIterator())
        }
    }
    
    private var nameIndex: MockTextIndex!
    
    override func setUp() {
        nameIndex = MockTextIndex()
    }
    
    override func tearDown() {
        nameIndex = nil
    }
    
    func testSearch_shouldReturnNothing_givenEmptyPrefixAndNoCities() {
        nameIndex.mockSearch = { query in
            XCTAssertEqual(query, "")
            return []
        }
        let subject = CitiesRepository(cities: [], nameIndex: nameIndex)
        let result = subject.searchByName(prefix: "")
        XCTAssertEqual(Array(result), [])
    }
    
    func testSearch_shouldReturnNothing_givenNonEmptyPrefixAndNoCities() {
        nameIndex.mockSearch = { query in
            XCTAssertEqual(query, "foobarbaz")
            return []
        }
        let subject = CitiesRepository(cities: [], nameIndex: nameIndex)
        let result = subject.searchByName(prefix: "foobarbaz")
        XCTAssertEqual(Array(result), [])
    }
    
    func testSearch_shouldReturnCity_givenExactPrefixMatchingCity() {
        let city = City(
            _id: 0,
            country: "AA",
            name: "fooville",
            coord: Coordinate(lon: 180, lat: -90)
        )
        nameIndex.mockSearch = { query in
            XCTAssertEqual(query, "fooville")
            return [0]
        }
        let subject = CitiesRepository(cities: [city], nameIndex: nameIndex)
        let result = subject.searchByName(prefix: "fooville")
        XCTAssertEqual(Array(result), [city])
    }
    
    func testSearch_shouldReturnCity_givenPrefixMatchingCity() {
        let city = City(
            _id: 0,
            country: "AA",
            name: "fooville",
            coord: Coordinate(lon: 180, lat: -90)
        )
        nameIndex.mockSearch = { query in
            XCTAssertEqual(query, "foo")
            return [0]
        }
        let subject = CitiesRepository(cities: [city], nameIndex: nameIndex)
        let result = subject.searchByName(prefix: "foo")
        XCTAssertEqual(Array(result), [city])
    }
    
    func testSearch_shouldReturnCities_givenPrefixMatchingCities() {
        let city0 = City(
            _id: 0,
            country: "AA",
            name: "fooville",
            coord: Coordinate(lon: 180, lat: -90)
        )
        let city1 = City(
            _id: 1,
            country: "AA",
            name: "footopia",
            coord: Coordinate(lon: 180, lat: -90)
        )
        nameIndex.mockSearch = { query in
            XCTAssertEqual(query, "foo")
            return [0, 1]
        }
        let subject = CitiesRepository(cities: [city0, city1], nameIndex: nameIndex)
        let result = subject.searchByName(prefix: "foo")
        XCTAssertEqual(Array(result), [city0, city1])
    }
    
    func testSearch_shouldReturnNothing_givenPrefixMatchingNoCities() {
        let city0 = City(
            _id: 0,
            country: "AA",
            name: "fooville",
            coord: Coordinate(lon: 180, lat: -90)
        )
        let city1 = City(
            _id: 1,
            country: "AA",
            name: "footopia",
            coord: Coordinate(lon: 180, lat: -90)
        )
        nameIndex.mockSearch = { query in
            XCTAssertEqual(query, "bar")
            return []
        }
        let subject = CitiesRepository(cities: [city0, city1], nameIndex: nameIndex)
        let result = subject.searchByName(prefix: "bar")
        XCTAssertEqual(Array(result), [])
    }
}

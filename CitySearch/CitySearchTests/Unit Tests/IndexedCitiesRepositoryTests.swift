import XCTest

@testable import CitySearch

final class IndexedCitiesRepositoryTests: XCTestCase {
    
    private var nameIndex: MockTextIndex!
    
    override func setUp() {
        nameIndex = MockTextIndex()
    }
    
    override func tearDown() {
        nameIndex = nil
    }
    
    #warning("TODO: Test unicode characters")

    #warning("TODO: Test invalid characters?")

    func testSearch_shouldReturnNothing_givenEmptyPrefixAndNoCities() async {
        nameIndex.mockSearch = { query in
            XCTAssertEqual(query, "")
            return []
        }
        let subject = IndexedCitiesRepository(cities: [], nameIndex: nameIndex)
        let result = await subject.searchByName(prefix: "")
        XCTAssertEqual(Array(result), [])
    }
    
    func testSearch_shouldReturnNothing_givenNonEmptyPrefixAndNoCities() async {
        nameIndex.mockSearch = { query in
            XCTAssertEqual(query, "foobarbaz")
            return []
        }
        let subject = IndexedCitiesRepository(cities: [], nameIndex: nameIndex)
        let result = await subject.searchByName(prefix: "foobarbaz")
        XCTAssertEqual(Array(result), [])
    }
    
    func testSearch_shouldReturnCity_givenExactPrefixMatchingCity() async {
        let city = City.foovilleAA()
        nameIndex.mockSearch = { query in
            XCTAssertEqual(query, "wellington")
            return [0]
        }
        let subject = IndexedCitiesRepository(cities: [city], nameIndex: nameIndex)
        let result = await subject.searchByName(prefix: "wellington")
        XCTAssertEqual(Array(result), [city])
    }
    
    func testSearch_shouldReturnCity_givenPrefixMatchingCity() async {
        let city = City.foovilleAA()
        nameIndex.mockSearch = { query in
            XCTAssertEqual(query, "foo")
            return [0]
        }
        let subject = IndexedCitiesRepository(cities: [city], nameIndex: nameIndex)
        let result = await subject.searchByName(prefix: "foo")
        XCTAssertEqual(Array(result), [city])
    }
    
    func testSearch_shouldReturnCities_givenPrefixMatchingCities() async {
        let city0 = City.foovilleAA()
        let city1 = City.footopiaAA()
        nameIndex.mockSearch = { query in
            XCTAssertEqual(query, "foo")
            return [0, 1]
        }
        let subject = IndexedCitiesRepository(cities: [city0, city1], nameIndex: nameIndex)
        let result = await subject.searchByName(prefix: "foo")
        XCTAssertEqual(Array(result), [city0, city1])
    }
    
    func testSearch_shouldReturnNothing_givenPrefixMatchingNoCities() async {
        let city0 = City.foovilleAA()
        let city1 = City.footopiaAA()
        nameIndex.mockSearch = { query in
            XCTAssertEqual(query, "bar")
            return []
        }
        let subject = IndexedCitiesRepository(cities: [city0, city1], nameIndex: nameIndex)
        let result = await subject.searchByName(prefix: "bar")
        XCTAssertEqual(Array(result), [])
    }
}

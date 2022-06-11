import XCTest

@testable import CitySearch

final class JSONCitiesRepositoryBuilderTests: XCTestCase {

    func testLoad_shouldLoadIndex_givenZeroCities() async throws {
        try await verifyLoad(
            json: """
                [
                ]
            """,
            cities: []
        )
    }

    func testLoad_shouldLoadIndex_givenOneCity() async throws {
        try await verifyLoad(
            json: """
                [
                    {
                        "country": "UA",
                        "name": "Hurzuf",
                        "_id": 707860,
                        "coord":{
                            "lon": 34.283333,
                            "lat": 44.549999
                        }
                    }
                ]
            """,
            cities: [
                City(
                    _id: 707860,
                    country: "UA",
                    name: "Hurzuf",
                    coord: Coordinate(
                        lon: 34.283333,
                        lat: 44.549999
                    )
                )
            ]
        )
    }
    
    func testLoad_shouldLoadIndex_givenTwoCities() async throws {
        try await verifyLoad(
            json: """
                [
                    {
                        "country": "UA",
                        "name": "Hurzuf",
                        "_id": 707860,
                        "coord":{
                            "lon": 34.283333,
                            "lat": 44.549999
                        }
                    },
                    {
                        "country": "US",
                        "name": "New York",
                        "_id": 5128638,
                        "coord":{
                            "lon": -74.005966,
                            "lat": 40.714272
                        }
                    }
                ]
            """,

            cities: [
                City(
                    _id: 707860,
                    country: "UA",
                    name: "Hurzuf",
                    coord: Coordinate(
                        lon: 34.283333,
                        lat: 44.549999
                    )
                ),
                City(
                    _id: 5128638,
                    country: "US",
                    name: "New York",
                    coord: Coordinate(
                        lon: -74.005966,
                        lat: 40.714272
                    )
                )
            ]
        )
    }
    private func verifyLoad(json: String, cities: [City], file: StaticString = #file, line: UInt = #line) async throws {
        let data = json.data(using: .utf8)!
        let subject = JSONCitiesRepositoryBuilder(data: data) { city in
            city.name
        }
        let result = try await subject.build()
        let allCities = await result.searchByName(prefix: "")
        XCTAssertEqual(Array(allCities), cities)
    }
}

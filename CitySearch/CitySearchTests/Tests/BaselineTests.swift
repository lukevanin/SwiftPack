import XCTest

@testable import CitySearch

final class BaselineTests: XCTestCase {

    ///    ```
    ///    {
    ///        "country":"UA",
    ///        "name":"Hurzuf",
    ///        "_id":707860,
    ///        "coord":{
    ///                "lon":34.283333,
    ///            "lat":44.549999
    ///        }
    ///    }
    ///    ```
    struct City: Decodable {
        struct Coordinate: Decodable {
            let lon: Double
            let lat: Double
        }
        let _id: Int
        let country: String
        let name: String
        let coord: Coordinate
    }

    ///
    /// Measure resources and time to load the raw JSON file into memory.
    ///
    func test_measure_withData_uncached() {
        let fileURL = Bundle.main.url(forResource: "cities", withExtension: "json")!
        measure(
            metrics: [
                XCTCPUMetric(limitingToCurrentThread: true),
                XCTMemoryMetric(),
                XCTClockMetric(),
            ],
            block: {
                do {
                    _ = try Data(contentsOf: fileURL, options: [.uncached])
                }
                catch {
                    XCTFail(error.localizedDescription)
                }
            }
        )
    }

    ///
    /// Measure resources and time to load the raw JSON file using memory mapping. This should take zero time, but we use this to account for possible overhead
    /// in other tests which actually use the data.
    ///
    func test_measure_withData_alwaysMapped() {
        let fileURL = Bundle.main.url(forResource: "cities", withExtension: "json")!
        measure(
            metrics: defaultMetrics(),
            block: {
                do {
                    _ = try Data(contentsOf: fileURL, options: [.alwaysMapped])
                }
                catch {
                    XCTFail(error.localizedDescription)
                }
            }
        )
    }

    func test_measure_withJSONDecoder() {
        let fileURL = Bundle.main.url(forResource: "cities", withExtension: "json")!
        let data = try! Data(contentsOf: fileURL, options: [.alwaysMapped])
        let decoder = JSONDecoder()
        measure(
            metrics: defaultMetrics(),
            block: {
                do {
                    let cities = try decoder.decode([City].self, from: data)
                    XCTAssertEqual(cities.count, 209557)
                }
                catch {
                    XCTFail(error.localizedDescription)
                }
            }
        )
    }

    func test_measure_withJSONSerialization() {
        let fileURL = Bundle.main.url(forResource: "cities", withExtension: "json")!
        let data = try! Data(contentsOf: fileURL, options: [.alwaysMapped])
        measure(
            metrics: defaultMetrics(),
            block: {
                do {
                    let cities = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray
                    XCTAssertEqual(cities?.count, 209557)
                }
                catch {
                    XCTFail(error.localizedDescription)
                }
            }
        )
    }
}

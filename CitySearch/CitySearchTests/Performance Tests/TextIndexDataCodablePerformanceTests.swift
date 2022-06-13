import XCTest

@testable import CitySearch

final class TextIndexDataCodablePerformanceTests: XCTestCase {
    
    func testJSONPerformance() throws {
        measure(metrics: defaultMetrics()) {
            let subject = try! loadCityData()
            XCTAssertEqual(Array(subject.search(prefix: "Witbank").iterator), [35999])
            XCTAssertEqual(Array(subject.search(prefix: "New York").iterator), [1340, 4818, 4846, 203003, 204085])
        }
    }

    func testDataCodablePerformance() throws {
        let surrogate = try loadCityData()
        let data = surrogate.data()

        measure(metrics: defaultMetrics()) {
            let subject = try! CaseInsensitiveTextIndex<TrieTextIndex<UInt32>>(data: data)
            XCTAssertEqual(Array(subject.search(prefix: "Witbank").iterator), [35999])
            XCTAssertEqual(Array(subject.search(prefix: "New York").iterator), [1340, 4818, 4846, 203003, 204085])
        }
    }
    
    ///
    ///
    ///
    private func loadCityData() throws -> CaseInsensitiveTextIndex<TrieTextIndex<UInt32>> {
        let url = Bundle.main.url(forResource: "cities", withExtension: "json")!
        let data = try Data(contentsOf: url, options: [.uncached])
        let decoder = JSONDecoder()
        let cities = try decoder.decode([City].self, from: data)
        var nameIndex = CaseInsensitiveTextIndex(TrieTextIndex<UInt32>())
        cities.enumerated().forEach { index, city in
            nameIndex.insert(key: city.name, value: UInt32(index))
        }
        return nameIndex
    }
    
}

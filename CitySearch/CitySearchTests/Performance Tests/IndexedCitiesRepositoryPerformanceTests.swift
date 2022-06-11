import XCTest

@testable import CitySearch

class IndexedCitiesRepositoryUnitTests: XCTestCase {
    
    private var subject: IndexedCitiesRepository!
    
    override func setUpWithError() throws {
        let url = Bundle.main.url(forResource: "cities", withExtension: "json")!
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let cities = try decoder.decode([City].self, from: data)
        var nameIndex = CaseInsensitiveTextIndex(index: TrieTextIndex())
        cities.enumerated().forEach { index, city in
            nameIndex.insert(key: city.name, value: index)
        }
        subject = IndexedCitiesRepository(cities: cities, nameIndex: nameIndex)
    }
    
    override func tearDown() {
        subject = nil
    }

    ///
    /// Test the performance of the`IndexedCitiesRepository` with the data set used in the
    /// application. The result sequence is converted to an array and counted, which causes the result
    /// array to be allocated. This emulates the behaviour of the app at runtime and gives an indication of
    /// the latency of the app as experienced by the user.
    ///
    func test_searchChecked() throws {
        let options = XCTMeasureOptions()
        measure(metrics: defaultMetrics(), options: options) {
            searchChecked()
        }
    }

    ///
    /// Test the performance of the`IndexedCitiesRepository` with the data set used in the
    /// application. The results are not checked.
    ///
    func test_searchUnchecked() throws {
        let options = XCTMeasureOptions()
        measure(metrics: defaultMetrics(), options: options) {
            searchUnchecked()
        }
    }
    
    ///
    /// Performs searches on the repository and checks the results.
    ///
    private func searchChecked(file: StaticString = #file, line: UInt = #line) {
        let queries = alphabetQueries()
        let group = DispatchGroup()
        group.enter()
        Task.detached { [subject] in
            for (query, count) in queries {
                let result = await subject!.searchByName(prefix: query)
                let actualCount = Array(result).count
                XCTAssertEqual(actualCount, count, "Expected \(count) for query '\(query)', but got \(actualCount)")
            }
            group.leave()
        }
        group.wait()
    }
    
    ///
    /// Performs searches on the repository but does not check the results..
    ///
    private func searchUnchecked(file: StaticString = #file, line: UInt = #line) {
        let queries = alphabetQueries()
        let group = DispatchGroup()
        group.enter()
        Task.detached { [subject] in
            for (query, _) in queries {
                _ = await subject!.searchByName(prefix: query)
            }
            group.leave()
        }
        group.wait()
    }

    ///
    ///
    ///
    private func alphabetQueries() -> [String: Int] {
        [
            "a": 11_207,
            "b": 17_198,
            "c": 15_301,
            "d": 7_195,
            "e": 4_999,
            "f": 4_864,
            "g": 9_039,
            "h": 7_760,
            "i": 2_559,
            "j": 2_774,
            "k": 10_159,
            "l": 12_095,
            "m": 15_235,
            "n": 7_133,
            "o": 5_077,
            "p": 13_152,
            "q": 1_077,
            "r": 7_943,
            "s": 24_435,
            "t": 9_144,
            "u": 2_004,
            "v": 6_993,
            "w": 6_572,
            "x": 879,
            "y": 1779,
            "z": 2_504
        ]
    }

}

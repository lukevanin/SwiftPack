import XCTest

@testable import CitySearch

final class LinearTextIndexPerformanceTests: TextIndexTestCase<LinearTextIndex<Int>> {

    func test_linearTextIndex_500_searchPerformance() {
        let testCase = makeTestCase(name: "500", count: 500)
        var subject = LinearTextIndex<Int>()
        fillTextIndex(&subject, with: testCase.data[0])
        measure(metrics: defaultMetrics()) {
            exerciseSearch(subject, with: testCase.queries, name: testCase.name, verify: false)
        }
    }

    func test_linearTextIndex_1k_searchPerformance() {
        let testCase = makeTestCase(name: "1k", count: 1_000)
        var subject = LinearTextIndex<Int>()
        fillTextIndex(&subject, with: testCase.data[0])
        measure(metrics: defaultMetrics()) {
            exerciseSearch(subject, with: testCase.queries, name: testCase.name, verify: false)
        }
    }
}

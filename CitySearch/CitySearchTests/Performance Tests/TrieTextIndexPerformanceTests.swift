import XCTest

@testable import CitySearch

///
///
final class TrieTextIndexPerformanceTests: TextIndexTestCase {

    func test_trieTextIndex_1k_searchPerformance() {
        let testCase = makeTestCase(name: "1k", count: 1_000)
        var subject = TrieTextIndex()
        fillTextIndex(&subject, with: testCase.data[0])
        measure(metrics: defaultMetrics()) {
            exerciseSearch(subject, with: testCase.queries, name: testCase.name, verify: false)
        }
    }
    
    func test_trieTextIndex_10k_searchPerformance() {
        let testCase = makeTestCase(name: "10k", count: 10_000)
        var subject = TrieTextIndex()
        fillTextIndex(&subject, with: testCase.data[0])
        measure(metrics: defaultMetrics()) {
            exerciseSearch(subject, with: testCase.queries, name: testCase.name, verify: false)
        }
    }
    
    func test_trieTextIndex_100k_searchPerformance() {
        let testCase = makeTestCase(name: "100k", count: 100_000)
        var subject = TrieTextIndex()
        fillTextIndex(&subject, with: testCase.data[0])
        measure(metrics: defaultMetrics()) {
            exerciseSearch(subject, with: testCase.queries, name: testCase.name, verify: false)
        }
    }
    
    func test_trieTextIndex_200k_searchPerformance() {
        let testCase = makeTestCase(name: "200k", count: 200_000)
        var subject = TrieTextIndex()
        fillTextIndex(&subject, with: testCase.data[0])
        measure(metrics: defaultMetrics()) {
            exerciseSearch(subject, with: testCase.queries, name: testCase.name, verify: false)
        }
    }
    
    func test_trieTextIndex_1m_searchPerformance() {
        let indices = Array((0 ..< 1_000_000))
        let elements = indices.map { (i: Int) -> Data in
            (key: String(format: "a%09d", i), value: i)
        }
        var subject = TrieTextIndex()
        elements.forEach { element in
            subject.insert(key: element.key, value: element.value)
        }
        measure(metrics: defaultMetrics()) {
            let _ = subject.search(prefix: "a000000000")
            let _ = subject.search(prefix: "a00000000")
            let _ = subject.search(prefix: "a0000000")
            let _ = subject.search(prefix: "a000000")
            let _ = subject.search(prefix: "a00000")
            let _ = subject.search(prefix: "a0000")
            let _ = subject.search(prefix: "a000")
            let _ = subject.search(prefix: "a00")
            XCTAssertEqual(Array(subject.search(prefix: "a000000000").iterator), [0])
            XCTAssertEqual(Array(subject.search(prefix: "a000555555").iterator), [555555])
            XCTAssertEqual(Array(subject.search(prefix: "a000999999").iterator), [999999])
        }
    }
}

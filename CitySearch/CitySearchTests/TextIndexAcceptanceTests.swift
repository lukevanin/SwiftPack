import XCTest

@testable import CitySearch

///
/// Tests based on the scenarios provided in the specification which prepresent the minimal acceptance
/// criteria. These are not comprehensive or sufficient for completeness.
///
/// We are using a data-driven approach to testing. This approach is not applicable to every
/// circumstance, but can be useful in situations such as ours where the subject is data oriented in nature.
///
/// In this particular case the approach works well as we mostly just want to push a lot of data through
/// the subject and check the outcome, with a very simple and repetative steps.
///
/// This also allows us to run identical tests on multiple different subjects. For our purposes we are using
/// this technique to rune tests against an oracle or reference implementation, to verify that the tests are
/// producing expected results. We run the same tests on our optimal solution(s) to verify their
/// correctness.
///
/// We define an array of test cases. Each test case consists of three pieces:
/// - data: Array of key-values we want to populate the subject with before performing testing.
/// - subscript scenarios: Array of key-values. We compare the value retrieved from the subject using
/// the key, to a known value.
/// - search scenarios: Array of key-values. We compare the search results from the subject using a
/// specific key against a known value.
///

final class TextIndexAcceptanceTests: XCTestCase {
    
    typealias Data = (key: String, value: Int)
    
    typealias SearchScenario = (query: String, results: [Int])
    
    struct TestCase {
        let name: String
        let data: [[Data]]
        let queries: [SearchScenario]
    }

    // MARK: Linear Index

    func test_linearTextIndex_minimal() {
        exerciseSubject(LinearTextIndex(), testCase: makeMinimalTestCase())
    }

    func test_linearTextIndex_empty() {
        exerciseSubject(LinearTextIndex(), testCase: makeEmptyTestCase())
    }

    func test_linearTextIndex_duplicatedValues() {
        exerciseSubject(LinearTextIndex(), testCase: makeDuplicatedValuesTestCase())
    }

    func test_linearTextIndex_duplicatedKeys() {
        exerciseSubject(LinearTextIndex(), testCase: makeDuplicatedKeysTestCase())
    }

    func test_linearTextIndex_100_entries() {
        exerciseSubject(LinearTextIndex(), testCase: makeTestCase(name: "100", count: 100))
    }

    func test_linearTextIndex_500_searchPerformance() {
        let testCase = makeTestCase(name: "500", count: 500)
        var subject = LinearTextIndex()
        fillSubject(&subject, with: testCase.data[0])
        measure(metrics: defaultMetrics()) {
            exerciseSearch(subject, with: testCase.queries, name: testCase.name, verify: false)
        }
    }

    func test_linearTextIndex_1k_searchPerformance() {
        let testCase = makeTestCase(name: "1k", count: 1_000)
        var subject = LinearTextIndex()
        fillSubject(&subject, with: testCase.data[0])
        measure(metrics: defaultMetrics()) {
            exerciseSearch(subject, with: testCase.queries, name: testCase.name, verify: false)
        }
    }

    // MARK: Trie Index
    
    func test_trieIndex_search_shouldReturnEmptySet_givenNoValues_noPrefix() {
        let subject = TrieTextIndex()
        let result = subject.search(prefix: "")
        XCTAssertEqual(Array(result), [])
    }

    func test_trieIndex_search_shouldReturnEmptySet_givenNoValues_somePrefix() {
        let subject = TrieTextIndex()
        let result = subject.search(prefix: "foo")
        XCTAssertEqual(Array(result), [])
    }

    func test_trieIndex_search_shouldReturnValue_givenOneValueForKey_exactPrefix() {
        var subject = TrieTextIndex()
        subject.insert(key: "foo", value: 7)
        let result = subject.search(prefix: "foo")
        XCTAssertEqual(Array(result), [7])
    }
    
    func test_trieIndex_search_shouldReturnValue_givenOneValueForKey_norefix() {
        var subject = TrieTextIndex()
        subject.insert(key: "foo", value: 7)
        let result = subject.search(prefix: "")
        XCTAssertEqual(Array(result), [7])
    }

    func test_trieIndex_search_shouldReturnEmptySet_givenOneValueForKey_mismatchPrefix() {
        var subject = TrieTextIndex()
        subject.insert(key: "foo", value: 7)
        let result = subject.search(prefix: "bar")
        XCTAssertEqual(Array(result), [])
    }

    func test_trieIndex_search_shouldReturnValues_givenMultipleOrderedValuesForKey_exactPrefix() {
        var subject = TrieTextIndex()
        subject.insert(key: "foo", value: 7)
        subject.insert(key: "foo", value: 13)
        let result = subject.search(prefix: "foo")
        XCTAssertEqual(Array(result), [7, 13])
    }

    func test_trieIndex_search_shouldReturnValues_givenMultipleOrderedValuesForKey_noPrefix() {
        var subject = TrieTextIndex()
        subject.insert(key: "foo", value: 7)
        subject.insert(key: "foo", value: 13)
        let result = subject.search(prefix: "")
        XCTAssertEqual(Array(result), [7, 13])
    }

    func test_trieIndex_search_shouldReturnValues_givenDuplicateValuesForKey_exactPrefix() {
        var subject = TrieTextIndex()
        subject.insert(key: "foo", value: 7)
        subject.insert(key: "foo", value: 13)
        subject.insert(key: "foo", value: 7)
        let result = subject.search(prefix: "foo")
        XCTAssertEqual(Array(result), [7, 13])
    }

    func test_trieIndex_search_shouldReturnValues_givenMultipleDeepOrderedValuesForKey_noPrefix() {
        var subject = TrieTextIndex()
        subject.insert(key: "f", value: 1)
        subject.insert(key: "fo", value: 3)
        subject.insert(key: "foo", value: 7)
        subject.insert(key: "foo", value: 13)
        let result = subject.search(prefix: "")
        XCTAssertEqual(Array(result), [1, 3, 7, 13])
    }

    func test_trieIndex_search_shouldReturnValuesInCorrectOrder_givenMultipleUnorderedValuesForKey_exactPrefix() {
        var subject = TrieTextIndex()
        subject.insert(key: "foo", value: 13)
        subject.insert(key: "foo", value: 7)
        let result = subject.search(prefix: "foo")
        XCTAssertEqual(Array(result), [7, 13])
    }
    
    func test_trieIndex_search_shouldReturnValues_givenMultipleKeys_exactPrefix() {
        var subject = TrieTextIndex()
        subject.insert(key: "foo", value: 7)
        subject.insert(key: "bar", value: 13)
        let result = subject.search(prefix: "foo")
        XCTAssertEqual(Array(result), [7])
    }

    func test_trieIndex_search_shouldReturnDescendantValues_givenOrderedDeepKeys_partialPrefix() {
        var subject = TrieTextIndex()
        subject.insert(key: "fo", value: 7)
        subject.insert(key: "foo", value: 13)
        let result = subject.search(prefix: "fo")
        XCTAssertEqual(Array(result), [7, 13])
    }

    func test_trieIndex_search_shouldReturnDescendantValues_givenUnorderedDeepKeys_partialPrefix() {
        var subject = TrieTextIndex()
        subject.insert(key: "foo", value: 13)
        subject.insert(key: "fo", value: 7)
        let result = subject.search(prefix: "fo")
        XCTAssertEqual(Array(result), [7, 13])
    }

    func test_trieIndex_search_shouldReturnDescendantValues_givenMultipleDeepKeys_partialPrefix() {
        var subject = TrieTextIndex()
        subject.insert(key: "bar", value: 19)
        subject.insert(key: "ba", value: 5)
        subject.insert(key: "fo", value: 7)
        subject.insert(key: "foo", value: 13)
        let result = subject.search(prefix: "fo")
        XCTAssertEqual(Array(result), [7, 13])
    }

    func test_trieIndex_search_shouldReturnDescendantValues_givenMultipleDeepOrderedKeys_noPrefix() {
        var subject = TrieTextIndex()
        subject.insert(key: "ba", value: 1)
        subject.insert(key: "bar", value: 3)
        subject.insert(key: "fo", value: 5)
        subject.insert(key: "foo", value: 7)
        let result = subject.search(prefix: "")
        XCTAssertEqual(Array(result), [1, 3, 5, 7])
    }

    func test_trieIndex_search_shouldReturnDescendantValues_givenMultipleUnorderedKeys_noPrefix() {
        var subject = TrieTextIndex()
        subject.insert(key: "foo", value: 7)
        subject.insert(key: "fo", value: 5)
        subject.insert(key: "bar", value: 3)
        subject.insert(key: "ba", value: 1)
        let result = subject.search(prefix: "")
        XCTAssertEqual(Array(result), [1, 3, 5, 7])
    }

    func test_trieIndex_search_shouldReturnDescendantValues_givenMultipleDeepDuplicateOrderedKeys_noPrefix() {
        var subject = TrieTextIndex()
        subject.insert(key: "ba", value: 1)
        subject.insert(key: "bar", value: 3)
        subject.insert(key: "barbar", value: 5)
        subject.insert(key: "fo", value: 7)
        subject.insert(key: "foo", value: 11)
        subject.insert(key: "foobar", value: 13)
        subject.insert(key: "ba", value: 1)
        subject.insert(key: "bar", value: 3)
        subject.insert(key: "barbar", value: 5)
        subject.insert(key: "fo", value: 7)
        subject.insert(key: "foo", value: 11)
        subject.insert(key: "foobar", value: 13)
        let result = subject.search(prefix: "")
        XCTAssertEqual(Array(result), [1, 3, 5, 7, 11, 13])
    }

    func test_trieTextIndex_minimal() {
        exerciseSubject(TrieTextIndex(), testCase: makeMinimalTestCase())
    }

    func test_trieTextIndex_empty() {
        exerciseSubject(TrieTextIndex(), testCase: makeEmptyTestCase())
    }

    func test_trieTextIndex_duplicatedValues() {
        exerciseSubject(TrieTextIndex(), testCase: makeDuplicatedValuesTestCase())
    }

    func test_trueTextIndex_duplicatedKeys() {
        exerciseSubject(TrieTextIndex(), testCase: makeDuplicatedKeysTestCase())
    }

    func test_trieTextIndex_100_entries() {
        exerciseSubject(TrieTextIndex(), testCase: makeTestCase(name: "100", count: 100))
    }

    //    func test_linearTextIndex_large_fillPerformance() {
    //        let testCase = makeLargeTestCase()
    //        var subject = LinearTextIndex()
    //        measure(metrics: defaultMetrics()) {
    //            fillSubject(&subject, with: testCase.data[0])
    //        }
    //    }
    
    func test_trieTextIndex_1k_searchPerformance() {
        let testCase = makeTestCase(name: "1k", count: 1_000)
        var subject = TrieTextIndex()
        fillSubject(&subject, with: testCase.data[0])
        measure(metrics: defaultMetrics()) {
            exerciseSearch(subject, with: testCase.queries, name: testCase.name, verify: false)
        }
    }
    
    func test_trieTextIndex_10k_searchPerformance() {
        let testCase = makeTestCase(name: "10k", count: 10_000)
        var subject = TrieTextIndex()
        fillSubject(&subject, with: testCase.data[0])
        measure(metrics: defaultMetrics()) {
            exerciseSearch(subject, with: testCase.queries, name: testCase.name, verify: false)
        }
    }
    
    func test_trieTextIndex_100k_searchPerformance() {
        let testCase = makeTestCase(name: "100k", count: 100_000)
        var subject = TrieTextIndex()
        fillSubject(&subject, with: testCase.data[0])
        measure(metrics: defaultMetrics()) {
            exerciseSearch(subject, with: testCase.queries, name: testCase.name, verify: false)
        }
    }
    
    func test_trieTextIndex_200k_searchPerformance() {
        let testCase = makeTestCase(name: "200k", count: 200_000)
        var subject = TrieTextIndex()
        fillSubject(&subject, with: testCase.data[0])
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
            XCTAssertEqual(Array(subject.search(prefix: "a000000000")), [0])
            XCTAssertEqual(Array(subject.search(prefix: "a000555555")), [555555])
            XCTAssertEqual(Array(subject.search(prefix: "a000999999")), [999999])
        }
    }

    // MARK: Helpers
    
    ///
    ///
    ///
    private func exerciseSubject<I>(_ makeSubject: @autoclosure () -> I, testCase: TestCase, file: StaticString = #file, line: UInt = #line) where I: TextIndex {
        testCase.data.forEach { data in
            // Create an instance of the subject
            var subject = makeSubject()
            // Fill the subject with data
            fillSubject(&subject, with: data)
            // Exercise the subject
            exerciseSearch(subject, with: testCase.queries, name: testCase.name, file: file, line: line)
        }
    }

    ///
    /// Fill the subject with data.
    ///
    private func fillSubject<I>(_ subject: inout I, with data: [Data]) where I: TextIndex {
        data.forEach { datum in
            subject.insert(key: datum.key, value: datum.value)
        }
    }
    
    ///
    /// Verify that the test subject returns the expected values for a given prefix.
    ///
    private func exerciseSearch<I>(_ subject: I, with scenarios: [SearchScenario], name: String, verify: Bool = true, file: StaticString = #file, line: UInt = #line) where I: TextIndex {
        scenarios.forEach { scenario in
            let results = Array(subject.search(prefix: scenario.query))
            if verify {
                XCTAssertEqual(results, scenario.results, "\(name) > Search > Expected \(scenario.results) for prefix \(scenario.query), but got \(results)", file: file, line: line)
            }
        }
    }
    
    ///
    /// A data set where keys are defined in alphabetical order
    ///
    /// We define a prefix string as: a substring that matches the initial characters of the target string. For
    /// instance, assume the following entries:
    ///
    /// * Alabama, US
    /// * Albuquerque, US
    /// * Anaheim, US
    /// * Arizona, US
    /// * Sydney, AU
    ///
    private func makeMinimalTestCase() -> TestCase {
        TestCase(
            name: "Minimal acceptance criteria",
            data: [
                // Original data set.
                [
                    (key: "alabama, us", value: 0),
                    (key: "albuquerque, us", value: 10),
                    (key: "anaheim, us", value: 2),
                    (key: "arizona, us", value: 30),
                    (key: "sydney, au", value: 4),
                ],
                // Original data in reverse order
                [
                    (key: "sydney, au", value: 4),
                    (key: "arizona, us", value: 30),
                    (key: "anaheim, us", value: 2),
                    (key: "albuquerque, us", value: 10),
                    (key: "alabama, us", value: 0),
                ],
                // Original data in random order.
                [
                    (key: "anaheim, us", value: 2),
                    (key: "albuquerque, us", value: 10),
                    (key: "alabama, us", value: 0),
                    (key: "sydney, au", value: 4),
                    (key: "arizona, us", value: 30),
                ],
                // Original data with some key+values duplicated.
                [
                    (key: "anaheim, us", value: 2),
                    (key: "anaheim, us", value: 2),
                    (key: "anaheim, us", value: 2),
                    (key: "albuquerque, us", value: 10),
                    (key: "alabama, us", value: 0),
                    (key: "albuquerque, us", value: 10),
                    (key: "sydney, au", value: 4),
                    (key: "arizona, us", value: 30),
                ],
            ],
            queries: [
                // If the given prefix is "A", all cities but Sydney should
                // appear.
                (query: "a", results: [0, 10, 2, 30]),

                // Contrariwise, if the given prefix is "s", the only result
                // should be "Sydney, AU".
                (query: "s", results: [4]),
             
                // If the given prefix is "Al", "Alabama, US" and "Albuquerque,
                // US" are the only results.
                (query: "al", results: [0, 10]),
                
                // If the prefix given is "Alb" then the only result is
                // "Albuquerque, US"
                (query: "alb", results: [10]),
                
                // If the prefix given is "" the all cities should be returned.
                (query: "", results: [0, 10, 2, 30, 4]),
                
                // If the prefix given is "Z" (matches no cities), then the
                // empty collection should be returned.
                (query: "z", results: []),
                
                // Additional scenarions
                (query: "alabama, us", results: [0]),
                (query: "albuquerque, us", results: [10]),
                (query: "anaheim, us", results: [2]),
                (query: "arizona, us", results: [30]),
                (query: "sydney, au", results: [4]),
                (query: "alabama, usa", results: []),
                (query: "alabama, u", results: [0]),
                (query: "z", results: []),
                (query: "", results: [0, 10, 2, 30, 4]),
            ]
        )
    }
       
    ///
    /// An empty data set.
    ///
    private func makeEmptyTestCase() -> TestCase {
        TestCase(
            name: "Empty",
            data: [],
            queries: [
                (query: "a", results: []),
                (query: "", results: []),
                (query: "alabama, us", results: []),
                (query: "albuquerque, us", results: []),
                (query: "anaheim, us", results: []),
                (query: "arizona, us", results: []),
                (query: "sydney, au", results: []),
            ]
        )
    }

    ///
    /// A data set where some of the values are duplicated. Values are independent of each other - the
    /// same value may exist for some or all of the keys in the index.
    ///
    private func makeDuplicatedValuesTestCase() -> TestCase {
        TestCase(
            name: "Duplicate values",
            data: [
                [
                    (key: "alabama, us", value: 0),
                    (key: "albuquerque, us", value: 0),
                    (key: "anaheim, us", value: 1),
                    (key: "arizona, us", value: 1),
                    (key: "sydney, au", value: 2),
                ]
            ],
            queries: [
                (query: "alabama, us", results: [0]),
                (query: "albuquerque, us", results: [0]),
                (query: "anaheim, us", results: [1]),
                (query: "arizona, us", results: [1]),
                (query: "sydney, au", results: [2]),
                (query: "z", results: []),
                (query: "a", results: [0, 0, 1, 1]),
                (query: "s", results: [2]),
                (query: "al", results: [0, 0]),
                (query: "alb", results: [0]),
                (query: "", results: [0, 0, 1, 1, 2]),
            ]
        )
    }
    
    ///
    /// A data set where some of the keys are duplicated. When a value is inserted with a key that already
    /// exists in the text index, the existing value should be replaced.
    ///
    private func makeDuplicatedKeysTestCase() -> TestCase {
        TestCase(
            name: "Duplicate keys",
            data: [
                [
                    (key: "alabama, us", value: 0),
                    (key: "alabama, us", value: 1),
                    (key: "anaheim, us", value: 2),
                    (key: "anaheim, us", value: 3),
                    (key: "sydney, au", value: 4),
                ]
            ],
            queries: [
                (query: "alabama, us", results: [0, 1]),
                (query: "albuquerque, us", results: []),
                (query: "anaheim, us", results: [2, 3]),
                (query: "sydney, au", results: [4]),
                (query: "a", results: [0, 1, 2, 3]),
                (query: "s", results: [4]),
                (query: "al", results: [0, 1]),
                (query: "alb", results: []),
                (query: "", results: [0, 1, 2, 3, 4]),
            ]
        )
    }

    ///
    /// Creates a test case scenario for a given number of elements.
    ///
    /// - Parameter name: Name of the test case reported in test failures.
    /// - Parameter count: Number of elements to include in the test case. Valid range is (100...)
    ///
    /// - Returns: A test case with a data set containing `count` number of elements, and verification
    /// criteria.
    ///
    private func makeTestCase(name: String, count: Int) -> TestCase {
        let indices = Array((0 ..< count))
        var queries = [SearchScenario]()
        queries.append(
            contentsOf: indices
                .suffix(1000)
                .map { i in
                    (query: String(format: "a%09d", i), results: [i])
                }
        )
        queries.append(
            contentsOf: [
                (query: "", results: indices),
                (query: "a", results: indices),
                (query: "a0", results: indices),
                (query: "a0000000", results: Array((0 ... 99))),
                (query: "a00000000", results: Array((0 ... 9))),
                (query: "a000000000", results: [0]),
                (query: "a000000009", results: [9]),
                (query: "z", results: []),
            ]
        )
        let testCase = TestCase(
            name: name,
            data:[
                indices.map { i in
                    (key: String(format: "a%09d", i), value: i)
                }
            ],
            queries: queries
        )
        return testCase
    }
}

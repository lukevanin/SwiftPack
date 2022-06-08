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
    
    typealias Data = (key: String, value: Int?)
    
    typealias SearchScenario = (query: String, results: [Int])
    
    typealias SubscriptScenario = (key: String, result: Int?)
    
    struct TestCase {
        let name: String
        let data: [[Data]]
        let subscriptScenarios: [SubscriptScenario]
        let searchScenarios: [SearchScenario]
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

    func test_linearTextIndex_nilValues() {
        exerciseSubject(LinearTextIndex(), testCase: makeNilValuesTestCase())
    }

    func test_linearTextIndex_medium() {
        exerciseSubject(LinearTextIndex(), testCase: makeMediumTestCase())
    }

    func test_linearTextIndex_large_fillPerformance() {
        let testCase = makeLargeTestCase()
        var subject = LinearTextIndex()
        measure(metrics: defaultMetrics()) {
            fillSubject(&subject, with: testCase.data[0])
        }
    }

    func test_linearTextIndex_large_subscriptPerformance() {
        let testCase = makeLargeTestCase()
        var subject = LinearTextIndex()
        fillSubject(&subject, with: testCase.data[0])
        measure(metrics: defaultMetrics()) {
            exerciseSubscript(subject, with: testCase.subscriptScenarios, name: testCase.name, verify: false)
        }
    }

    func test_linearTextIndex_large_searchPerformance() {
        let testCase = makeLargeTestCase()
        var subject = LinearTextIndex()
        fillSubject(&subject, with: testCase.data[0])
        measure(metrics: defaultMetrics()) {
            exerciseSearch(subject, with: testCase.searchScenarios, name: testCase.name, verify: false)
        }
    }
    
    // MARK: Trie Index

    func test_trieTextIndex_minimal() {
        exerciseSubject(TrieTextIndex(), testCase: makeMinimalTestCase())
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
            exerciseSubject(subject, with: testCase, file: file, line: line)
        }
    }

    ///
    /// Fill the subject with data.
    ///
    private func fillSubject<I>(_ subject: inout I, with data: [Data]) where I: TextIndex {
        data.forEach { datum in
            subject[datum.key] = datum.value
        }
    }
    
    ///
    /// Exercise the subject under various conditions..
    ///
    private func exerciseSubject<I>(_ subject: I, with testCase: TestCase, file: StaticString = #file, line: UInt = #line) where I: TextIndex {
        exerciseSubscript(subject, with: testCase.subscriptScenarios, name: testCase.name, file: file, line: line)
        exerciseSearch(subject, with: testCase.searchScenarios, name: testCase.name, file: file, line: line)
    }

    ///
    /// Verify that the test subject returns the expected value for a given key.
    ///
    private func exerciseSubscript<I>(_ subject: I, with scenarios: [SubscriptScenario], name: String, verify: Bool = true, file: StaticString = #file, line: UInt = #line) where I: TextIndex {
        scenarios.forEach { scenario in
            let result = subject[scenario.key]
            if verify {
                XCTAssertEqual(result, scenario.result, "\(name) > Subscript > Expected \(scenario.result.map { String($0) } ?? "nil") for key \(scenario.key), but got \(result.map { String($0) } ?? "nil")", file: file, line: line)
            }
        }
    }
    
    ///
    /// Verify that the test subject returns the expected values for a given prefix.
    ///
    private func exerciseSearch<I>(_ subject: I, with scenarios: [SearchScenario], name: String, verify: Bool = true, file: StaticString = #file, line: UInt = #line) where I: TextIndex {
        scenarios.forEach { scenario in
            let results = subject.search(prefix: scenario.query)
            if verify {
                XCTAssertEqual(Array(results), scenario.results, "\(name) > Search > Expected \(scenario.results) for prefix \(scenario.query), but got \(results)", file: file, line: line)
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
            name: "Specification",
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
                // Original data with some keys duplicated.
                [
                    (key: "anaheim, us", value: 2),
                    (key: "albuquerque, us", value: 10),
                    (key: "anaheim, us", value: 2),
                    (key: "alabama, us", value: 0),
                    (key: "sydney, au", value: 4),
                    (key: "albuquerque, us", value: 10),
                    (key: "arizona, us", value: 30),
                    (key: "sydney, au", value: 4),
                ],
            ],
            subscriptScenarios: [
                (key: "alabama, us", result: 0),
                (key: "albuquerque, us", result: 10),
                (key: "anaheim, us", result: 2),
                (key: "arizona, us", result: 30),
                (key: "sydney, au", result: 4),
                (key: "alabama, usa", result: nil),
                (key: "alabama, u", result: nil),
                (key: "z", result: nil),
                (key: "", result: nil),
            ],
            searchScenarios: [
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
            subscriptScenarios: [
                (key: "alabama, us", result: nil),
                (key: "albuquerque, us", result: nil),
                (key: "anaheim, us", result: nil),
                (key: "arizona, us", result: nil),
                (key: "sydney, au", result: nil),
            ],
            searchScenarios: [
                (query: "a", results: []),
                (query: "", results: []),
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
            subscriptScenarios: [
                (key: "alabama, us", result: 0),
                (key: "albuquerque, us", result: 0),
                (key: "anaheim, us", result: 1),
                (key: "arizona, us", result: 1),
                (key: "sydney, au", result: 2),
                (key: "z", result: nil),
                (key: "", result: nil),
            ],
            searchScenarios: [
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
            subscriptScenarios: [
                (key: "alabama, us", result: 1),
                (key: "albuquerque, us", result: nil),
                (key: "anaheim, us", result: 3),
                (key: "arizona, us", result: nil),
                (key: "sydney, au", result: 4),
            ],
            searchScenarios: [
                (query: "a", results: [1, 3]),
                (query: "s", results: [4]),
                (query: "al", results: [1]),
                (query: "alb", results: []),
                (query: "", results: [1, 3, 4]),
            ]
        )
    }
      
    ///
    /// A data set where some values are nil.
    ///
    private func makeNilValuesTestCase() -> TestCase {
        TestCase(
            name: "Nils",
            data: [
                [
                    (key: "alabama, us", value: 0),
                    (key: "alabama, us", value: nil),
                    (key: "albuquerque, us", value: nil),
                    (key: "albuquerque, us", value: 10),
                    (key: "anaheim, us", value: nil),
                    (key: "sydney, au", value: 4),
                ]
            ],
            subscriptScenarios: [
                (key: "alabama, us", result: nil),
                (key: "albuquerque, us", result: 10),
                (key: "anaheim, us", result: nil),
                (key: "arizona, us", result: nil),
                (key: "sydney, au", result: 4),
                (key: "z", result: nil),
                (key: "", result: nil),
            ],
            searchScenarios: [
                (query: "a", results: [10]),
                (query: "s", results: [4]),
                (query: "al", results: [10]),
                (query: "alb", results: [10]),
                (query: "an", results: []),
                (query: "", results: [10, 4]),
            ]
        )
    }
    
    ///
    /// A medium sized data set.
    ///
    private func makeMediumTestCase() -> TestCase {
        makeTestCase(name: "Medium", count: 100)
    }
    
    ///
    /// A lerger sized data set containing more values.
    ///
    private func makeLargeTestCase() -> TestCase {
        makeTestCase(name: "Large", count: 2_000)
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
        let testCase = TestCase(
            name: name,
            data:[
                indices.map { i in
                    (key: String(format: "a%09d", i), value: i)
                }
            ],
            subscriptScenarios: indices.map { i in
                (key: String(format: "a%09d", i), result: i)
            },
            searchScenarios: [
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
        return testCase
    }
}

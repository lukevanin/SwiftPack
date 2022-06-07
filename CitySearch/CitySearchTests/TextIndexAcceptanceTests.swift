import XCTest

@testable import CitySearch

///
/// Tests based on the scenarios provided in the specification which prepresent the minimal acceptance
/// criteria. These are not comprehensive or sufficient for completeness.
///
final class TextIndexAcceptanceTests: XCTestCase {
    
    typealias Data = (key: String, value: Int)
    
    typealias SearchScenario = (query: String, results: [Int])
    
    typealias SubscriptScenario = (key: String, result: Int?)
    
    struct TestCase {
        let name: String
        let data: [[Data]]
        let subscriptScenarios: [SubscriptScenario]
        let searchScenarios: [SearchScenario]
    }

    ///
    /// Data for different cases we want to test. We are using a data-driven approach to testing. This
    /// approach is not applicable to every circumstance, but can be useful in situations where the subject
    /// is data oriented in nature.
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
    private let testCases = [
        // A data set where keys are defined in alphabetical order
        // We define a prefix string as: a substring that matches the initial
        // characters of the target string. For instance, assume the following
        // entries:
        //
        // * Alabama, US
        // * Albuquerque, US
        // * Anaheim, US
        // * Arizona, US
        // * Sydney, AU
        //
        // Note: We use values of `10` and `30` for some keys as a way to check that
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
        ),
        
        // A data set where some of the values are duplicated. Values are
        // independent of each other - the same value may exist for some or all
        // of the keys in the index.
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
        ),
        
        // A data set where some of the keys are duplicated. When a value is
        // inserted with a key that already exists in the text index, the
        // existing value should be replaced.
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
        ),
    ]

    // MARK: Linear Index

    func test_linearTextIndex() {
        exerciseSubject(LinearTextIndex())
    }
    
    ///
    ///
    ///
    private func exerciseSubject<I>(_ makeSubject: @autoclosure () -> I, file: StaticString = #file, line: UInt = #line) where I: TextIndex {
        testCases.forEach { testCase in
            testCase.data.forEach { data in
                // Create an instance of the subject
                var subject = makeSubject()
                // Fill the subject with data
                fillSubject(&subject, with: data)
                // Exercise the subject
                exerciseSubject(subject, with: testCase, file: file, line: line)
            }
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
    private func exerciseSubscript<I>(_ subject: I, with scenarios: [SubscriptScenario], name: String, file: StaticString = #file, line: UInt = #line) where I: TextIndex {
        scenarios.forEach { scenario in
            let result = subject[scenario.key]
            XCTAssertEqual(result, scenario.result, "\(name) > Subscript > Expected \(scenario.result.map { String($0) } ?? "nil") for key \(scenario.key), but got \(result.map { String($0) } ?? "nil")", file: file, line: line)
        }
    }
    
    ///
    /// Verify that the test subject returns the expected values for a given prefix.
    ///
    private func exerciseSearch<I>(_ subject: I, with scenarios: [SearchScenario], name: String, file: StaticString = #file, line: UInt = #line) where I: TextIndex {
        scenarios.forEach { scenario in
            let results = subject.search(prefix: scenario.query)
            XCTAssertEqual(results, scenario.results, "\(name) > Search > Expected \(scenario.results) for prefix \(scenario.query), but got \(results)", file: file, line: line)
        }
    }
}

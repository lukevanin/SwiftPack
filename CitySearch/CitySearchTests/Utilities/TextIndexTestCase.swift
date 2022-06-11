import XCTest

@testable import CitySearch

class TextIndexTestCase: XCTestCase {
    
    typealias Data = (key: String, value: Int)
    
    typealias SearchScenario = (query: String, results: [Int])
    
    struct TestCase {
        let name: String
        let data: [[Data]]
        let queries: [SearchScenario]
    }

    ///
    ///
    ///
    func exerciseTextIndex<I>(_ makeSubject: @autoclosure () -> I, testCase: TestCase, file: StaticString = #file, line: UInt = #line) where I: TextIndex {
        testCase.data.forEach { data in
            // Create an instance of the subject
            var subject = makeSubject()
            // Fill the subject with data
            fillTextIndex(&subject, with: data)
            // Exercise the subject
            exerciseSearch(subject, with: testCase.queries, name: testCase.name, file: file, line: line)
        }
    }

    ///
    /// Fill the subject with data.
    ///
    func fillTextIndex<I>(_ subject: inout I, with data: [Data]) where I: TextIndex {
        data.forEach { datum in
            subject.insert(key: datum.key, value: datum.value)
        }
    }
    
    ///
    /// Verify that the test subject returns the expected values for a given prefix.
    ///
    func exerciseSearch<I>(_ subject: I, with scenarios: [SearchScenario], name: String, verify: Bool = true, file: StaticString = #file, line: UInt = #line) where I: TextIndex {
        scenarios.forEach { scenario in
            let results = Array(subject.search(prefix: scenario.query).iterator)
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
    func makeMinimalTestCase() -> TestCase {
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
    func makeEmptyTestCase() -> TestCase {
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
    func makeDuplicatedValuesTestCase() -> TestCase {
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
    func makeDuplicatedKeysTestCase() -> TestCase {
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
    func makeTestCase(name: String, count: Int) -> TestCase {
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

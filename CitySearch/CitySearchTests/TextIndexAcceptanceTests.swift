import XCTest

@testable import CitySearch

///
/// Tests based on the scenarios provided in the specification which prepresent the minimal acceptance
/// criteria. These are not comprehensive or sufficient for completeness.
///
final class TextIndexAcceptanceTests: XCTestCase {
    
    /// We define a prefix string as: a substring that matches the initial characters of the target string. For
    ///  instance, assume the following entries:
    /// * Alabama, US
    /// * Albuquerque, US
    /// * Anaheim, US
    /// * Arizona, US
    /// * Sydney, AU
    private let data = [
        (key: "alabama, us", value: 0),
        (key: "albuquerque, us", value: 1),
        (key: "anaheim, us", value: 2),
        (key: "arizona, us", value: 3),
        (key: "sydney, au", value: 4),
    ]

    private let subscriptScenarios = [
        (key: "alabama, us", result: 0),
        (key: "albuquerque, us", result: 1),
        (key: "anaheim, us", result: 2),
        (key: "arizona, us", result: 3),
        (key: "sydney, au", result: 4),
        (key: "alabama, usa", result: nil),
        (key: "alabama, u", result: nil),
        (key: "z", result: nil),
        (key: "", result: nil),
    ]

    private let searchScenarios = [
        // If the given prefix is "A", all cities but Sydney should appear.
        (query: "a", results: [0, 1, 2, 3]),

        // Contrariwise, if the given prefix is "s", the only result should be
        // "Sydney, AU".
        (query: "s", results: [4]),
     
        // If the given prefix is "Al", "Alabama, US" and "Albuquerque, US" are
        // the only results.
        (query: "al", results: [0, 1]),
        
        // If the prefix given is "Alb" then the only result is
        // "Albuquerque, US"
        (query: "alb", results: [1]),
        
        // If the prefix given is "" the all cities should be returned.
        (query: "", results: [0, 1, 2, 3, 4]),
        
        // If the prefix given is "Z" (matches no cities), then the empty
        // collection should be returned.
        (query: "z", results: []),
    ]

    func test_linearTextIndex_subscript() {
        var subject = LinearTextIndex()
        setupSubject(&subject)
        exerciseSubscript(subject)
    }

    func test_linearTextIndex_search() {
        var subject = LinearTextIndex()
        setupSubject(&subject)
        exerciseSearch(subject)
    }

    private func setupSubject<I>(_ subject: inout I) where I: TextIndex {
        // Populate the test subject
        data.forEach { datum in
            subject[datum.key] = datum.value
        }
    }

    /// Verify that the test subject returns the expected value for a given key.
    private func exerciseSubscript<I>(_ subject: I, file: StaticString = #file, line: UInt = #line) where I: TextIndex {
        subscriptScenarios.forEach { scenario in
            let result = subject[scenario.key]
            XCTAssertEqual(result, scenario.result, "Expected \(scenario.result.map { String($0) } ?? "nil") for key \(scenario.key), but got \(result.map { String($0) } ?? "nil")", file: file, line: line)
        }
    }
    
    /// Verify that the test subject returns the expected values for a given prefix.
    private func exerciseSearch<I>(_ subject: I, file: StaticString = #file, line: UInt = #line) where I: TextIndex {
        searchScenarios.forEach { scenario in
            let results = subject.search(prefix: scenario.query)
            XCTAssertEqual(results, scenario.results, "Expected \(scenario.results) for prefix \(scenario.query), but got \(results)", file: file, line: line)
        }
    }
}

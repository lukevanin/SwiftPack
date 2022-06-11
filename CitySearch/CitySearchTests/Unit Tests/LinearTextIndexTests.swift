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

final class TextIndexAcceptanceTests: TextIndexTestCase {

    // MARK: Linear Index

    func test_linearTextIndex_minimal() {
        exerciseTextIndex(LinearTextIndex(), testCase: makeMinimalTestCase())
    }

    func test_linearTextIndex_empty() {
        exerciseTextIndex(LinearTextIndex(), testCase: makeEmptyTestCase())
    }

    func test_linearTextIndex_duplicatedValues() {
        exerciseTextIndex(LinearTextIndex(), testCase: makeDuplicatedValuesTestCase())
    }

    func test_linearTextIndex_duplicatedKeys() {
        exerciseTextIndex(LinearTextIndex(), testCase: makeDuplicatedKeysTestCase())
    }

    func test_linearTextIndex_100_entries() {
        exerciseTextIndex(LinearTextIndex(), testCase: makeTestCase(name: "100", count: 100))
    }

}

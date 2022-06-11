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

final class TrieTextIndexAcceptanceTests: TextIndexTestCase {

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
        exerciseTextIndex(TrieTextIndex(), testCase: makeMinimalTestCase())
    }

    func test_trieTextIndex_empty() {
        exerciseTextIndex(TrieTextIndex(), testCase: makeEmptyTestCase())
    }

    func test_trieTextIndex_duplicatedValues() {
        exerciseTextIndex(TrieTextIndex(), testCase: makeDuplicatedValuesTestCase())
    }

    func test_trueTextIndex_duplicatedKeys() {
        exerciseTextIndex(TrieTextIndex(), testCase: makeDuplicatedKeysTestCase())
    }

    func test_trieTextIndex_100_entries() {
        exerciseTextIndex(TrieTextIndex(), testCase: makeTestCase(name: "100", count: 100))
    }
}

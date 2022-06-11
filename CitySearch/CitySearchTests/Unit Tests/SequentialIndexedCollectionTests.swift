import XCTest
@testable import CitySearch

final class SequentialIndexedCollectionTests: XCTestCase {
    
    func testCount_shouldEqualZero_givenEmptySequence() {
        let subject = SequentialIndexedCollection(
            count: 0,
            indices: [].makeIterator(),
            elements: []
        )
        XCTAssertEqual(subject.count, 0)
    }
    
    func testCount_shouldEqualCount_givenNonEmptySequence() {
        let subject = SequentialIndexedCollection(
            count: 1,
            indices: [].makeIterator(),
            elements: []
        )
        XCTAssertEqual(subject.count, 1)
    }
    
    func testSubscript_shouldReturnFirstElement_givenNonEmptySequence() {
        let subject = SequentialIndexedCollection(
            count: 2,
            indices: [0, 1].makeIterator(),
            elements: ["foo", "bar"]
        )
        XCTAssertEqual(subject[0], "foo")
    }

    func testSubscript_shouldReturnLastElement_givenNonEmptySequence() {
        let subject = SequentialIndexedCollection(
            count: 2,
            indices: [0, 1].makeIterator(),
            elements: ["foo", "bar"]
        )
        XCTAssertEqual(subject[1], "bar")
    }

    func testSubscript_shouldReturnAllElements_givenNonEmptySequence() {
        let elements = ["foo", "bar"]
        let subject = SequentialIndexedCollection(
            count: 2,
            indices: [0, 1].makeIterator(),
            elements: elements
        )
        for i in 0 ..< subject.count {
            XCTAssertEqual(subject[i], elements[i])
        }
    }
}

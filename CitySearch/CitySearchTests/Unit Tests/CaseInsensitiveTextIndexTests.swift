import XCTest

@testable import CitySearch

final class CaseInsensitiveTextIndexTests: XCTestCase {
    
    struct DictionaryTextIndex: TextIndex {
        
        var keyValues = [(String, Int)]()
        
        mutating func insert(key: String, value: Int) {
            keyValues.append((key, value))
        }
        
        func search<S>(prefix: S) -> TextIndexSearchResult<Int> where S : StringProtocol {
            let values = keyValues
                .filter { (key, value) in
                    key.prefix(prefix.count) == prefix
                }
                .map { (key, value) in
                    value
                }
            return TextIndexSearchResult(
                count: values.count,
                iterator: AnyIterator(values.makeIterator())
            )
        }
    }
    
    private var control: DictionaryTextIndex!
    private var subject: CaseInsensitiveTextIndex<DictionaryTextIndex>!
    
    override func setUp() {
        control = DictionaryTextIndex()
        subject = CaseInsensitiveTextIndex(control)
    }
    
    override func tearDown() {
        control = nil
        subject = nil
    }
    
    func testSearch_shouldReturnValues_givenNoPrefix() {
        control.insert(key: "foo", value: 7)
        subject.insert(key: "foo", value: 7)
        let controlResult = control.search(prefix: "")
        let testResult = subject.search(prefix: "")
        XCTAssertEqual(Array(controlResult.iterator), [7])
        XCTAssertEqual(Array(testResult.iterator), [7])
    }

    func testSearch_shouldReturnValue_givenLowerCaseKeyAndPrefix() {
        control.insert(key: "foo", value: 7)
        subject.insert(key: "foo", value: 7)
        let controlResult = control.search(prefix: "foo")
        let testResult = subject.search(prefix: "foo")
        XCTAssertEqual(Array(controlResult.iterator), [7])
        XCTAssertEqual(Array(testResult.iterator), [7])
    }
    
    func testSearch_shouldReturnValue_givenUpperCaseKeyAndPrefix() {
        control.insert(key: "FOO", value: 7)
        subject.insert(key: "FOO", value: 7)
        let controlResult = control.search(prefix: "FOO")
        let testResult = subject.search(prefix: "FOO")
        XCTAssertEqual(Array(controlResult.iterator), [7])
        XCTAssertEqual(Array(testResult.iterator), [7])
    }

    func testSearch_shouldReturnValue_givenLowercaseKeyAndUppercasePrefix() {
        control.insert(key: "foo", value: 7)
        subject.insert(key: "foo", value: 7)
        let controlResult = control.search(prefix: "FOO")
        let testResult = subject.search(prefix: "FOO")
        XCTAssertEqual(Array(controlResult.iterator), [])
        XCTAssertEqual(Array(testResult.iterator), [7])
    }
    
    func testSearch_shouldReturnValue_givenUppercaseKeyAndLowercasePrefix() {
        control.insert(key: "FOO", value: 7)
        subject.insert(key: "FOO", value: 7)
        let controlResult = control.search(prefix: "foo")
        let testResult = subject.search(prefix: "foo")
        XCTAssertEqual(Array(controlResult.iterator), [])
        XCTAssertEqual(Array(testResult.iterator), [7])
    }
}

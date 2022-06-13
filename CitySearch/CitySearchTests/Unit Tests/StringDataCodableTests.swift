import XCTest

@testable import CitySearch

final class StringDataCodableTests: XCTestCase {
    
    // MARK: Encode
    
    func testEncode_shouldReturnLength_givenZeroValues() {
        let value = ""
        let data = [UInt8](value.data())
        XCTAssertEqual(data, [0x00])
    }
    
    func testEncode_shouldReturnLengthAndValue_givenOneValue() {
        let value = " "
        let data = [UInt8](value.data())
        XCTAssertEqual(data, [0x01, 0x20])
    }
    
    func testEncode_shouldReturnLengthAndValues_givenSomeValues() {
        let value = " \n"
        let data = [UInt8](value.data())
        XCTAssertEqual(data, [0x02, 0x20, 0x0a])
    }
    
    func testEncode_returnMultipleBytes_givenSingleCharacter() {
        let value = "🏴󠁧󠁢󠁳󠁣󠁴󠁿"
        let data = [UInt8](value.data())
        XCTAssertEqual(data, [28, 240, 159, 143, 180, 243, 160, 129, 167, 243, 160, 129, 162, 243, 160, 129, 179, 243, 160, 129, 163, 243, 160, 129, 180, 243, 160, 129, 191])
    }
    
    // MARK: Decode
    
    func testDecode_shouldReturnZeroValues_givenZeroLength() throws {
        let data = Data([0x00])
        let value = try String(data: data)
        XCTAssertEqual(value, "")
    }
    
    func testDecode_shouldReturnOneValue_givenLengthAndValue() throws {
        let data = Data([0x01, 0x20])
        let value = try String(data: data)
        XCTAssertEqual(value, " ")
    }
    
    func testDecode_shouldReturnValues_givenLengthAndValues() throws {
        let data = Data([0x02, 0x20, 0x0a])
        let value = try String(data: data)
        XCTAssertEqual(value, " \n")
    }
    
    func testDecode_shouldReturnSingleCharacter_givenMultipleBytes() throws {
        let data = Data([28, 240, 159, 143, 180, 243, 160, 129, 167, 243, 160, 129, 162, 243, 160, 129, 179, 243, 160, 129, 163, 243, 160, 129, 180, 243, 160, 129, 191])
        let value = try String(data: data)
        XCTAssertEqual(value, "🏴󠁧󠁢󠁳󠁣󠁴󠁿")
    }
}

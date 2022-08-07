///
/// Copright (c) 2022 Luke Van In
///
import XCTest

@testable import SwiftPack

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
        XCTAssertEqual(data, [
            0x1c,
            0xf0, 0x9f, 0x8f, 0xb4, 0xf3, 0xa0, 0x81, 0xa7,
            0xf3, 0xa0, 0x81, 0xa2, 0xf3, 0xa0, 0x81, 0xb3,
            0xf3, 0xa0, 0x81, 0xa3, 0xf3, 0xa0, 0x81, 0xb4,
            0xf3, 0xa0, 0x81, 0xbf
        ])
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
        let data = Data([
            0x1c,
            0xf0, 0x9f, 0x8f, 0xb4, 0xf3, 0xa0, 0x81, 0xa7,
            0xf3, 0xa0, 0x81, 0xa2, 0xf3, 0xa0, 0x81, 0xb3,
            0xf3, 0xa0, 0x81, 0xa3, 0xf3, 0xa0, 0x81, 0xb4,
            0xf3, 0xa0, 0x81, 0xbf
        ])
        let value = try String(data: data)
        XCTAssertEqual(value, "🏴󠁧󠁢󠁳󠁣󠁴󠁿")
    }
}

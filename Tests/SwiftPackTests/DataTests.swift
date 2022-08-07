///
/// Copright (c) 2022 Luke Van In
///
import XCTest

@testable import SwiftPack

final class DataDataCodableTests: XCTestCase {
    
    // MARK: Encode
    
    func testEncode_shouldReturnLength_givenZeroValues() {
        let value = Data([])
        let data = value.data()
        XCTAssertEqual(data, Data([0x00]))
    }
    
    func testEncode_shouldReturnLengthAndValue_givenOneValue() {
        let value = Data([0x81])
        let data = value.data()
        XCTAssertEqual(data, Data([0x01, 0x81]))
    }
    
    func testEncode_shouldReturnLengthAndValues_givenSomeValues() {
        let value = Data([0x81, 0xc3])
        let data = value.data()
        XCTAssertEqual(data, Data([0x02, 0x81, 0xc3]))
    }
    
    // MARK: Decode
    
    func testDecode_shouldReturnZeroValues_givenZeroLength() throws {
        let data = Data([0x00])
        let value = try Data(data: data)
        XCTAssertEqual(value, Data([]))
    }
    
    func testDecode_shouldReturnOneValue_givenLengthAndValue() throws {
        let data = Data([0x01, 0x81])
        let value = try Data(data: data)
        XCTAssertEqual(value, Data([0x81]))
    }
    
    func testDecode_shouldReturnValues_givenLengthAndValues() throws {
        let data = Data([0x02, 0x81, 0xc3])
        let value = try Data(data: data)
        XCTAssertEqual(value, Data([0x81, 0xc3]))
    }
}

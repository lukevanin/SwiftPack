import XCTest

@testable import CitySearch

final class DictionaryDataCodableTests: XCTestCase {
    
    // MARK: Encode
    
    func testEncode_shouldReturnLength_givenZeroValues() {
        let value: [UInt8: UInt8] = [:]
        let data = [UInt8](value.data())
        XCTAssertEqual(data, [0x00])
    }
    
    func testEncode_shouldReturnLengthAndValue_givenOneValue() {
        let value: [UInt8: UInt8] = [0x07: 0x81]
        let data = [UInt8](value.data())
        XCTAssertEqual(data, [0x01, 0x07, 0x81])
    }
    
    func testEncode_shouldReturnLengthAndValues_givenSomeValues() {
        let value: [UInt8: UInt8] = [0x0f: 0x81, 0x07: 0xc3]
        let data = [UInt8](value.data())
        XCTAssertEqual(data, [0x02, 0x07, 0xc3, 0x0f, 0x81])
    }
    
    // MARK: Decode
    
    func testDecode_shouldReturnZeroValues_givenZeroLength() throws {
        let data = Data([0x00])
        let value = try [UInt8: UInt8](data: data)
        XCTAssertEqual(value, [:])
    }
    
    func testDecode_shouldReturnOneValue_givenLengthAndValue() throws {
        let data = Data([0x01, 0x07, 0x81])
        let value = try [UInt8: UInt8](data: data)
        XCTAssertEqual(value, [0x07: 0x81])
    }
    
    func testDecode_shouldReturnValues_givenLengthAndValues() throws {
        let data = Data([0x02, 0x07, 0x81, 0x03, 0xc3])
        let value = try [UInt8: UInt8](data: data)
        XCTAssertEqual(value, [0x07: 0x81, 0x03: 0xc3])
    }
}

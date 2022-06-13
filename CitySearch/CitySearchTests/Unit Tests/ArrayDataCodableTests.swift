import XCTest

@testable import CitySearch

final class ArrayDataCodableTests: XCTestCase {
    
    // MARK: Encode
    
    func testEncode_shouldReturnLength_givenZeroValues() {
        let value: [UInt8] = []
        let data = [UInt8](value.data())
        XCTAssertEqual(data, [0x00])
    }
    
    func testEncode_shouldReturnLengthAndValue_givenOneValue() {
        let value: [UInt8] = [0x81]
        let data = [UInt8](value.data())
        XCTAssertEqual(data, [0x01, 0x81])
    }
    
    func testEncode_shouldReturnLengthAndValues_givenSomeValues() {
        let value: [UInt8] = [0x81, 0xc3]
        let data = [UInt8](value.data())
        XCTAssertEqual(data, [0x02, 0x81, 0xc3])
    }
    
    // MARK: Decode
}

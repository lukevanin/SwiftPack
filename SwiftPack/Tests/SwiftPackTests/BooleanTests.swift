///
/// Copright (c) 2022 Luke Van In
///
import XCTest

@testable import SwiftPack

final class BooleanDataCodableTests: XCTestCase {
    
    // MARK: Encode
    
    func test_encode_shouldReturnZero_givenFalse() {
        let value: Bool = false
        let data = [UInt8](value.data())
        XCTAssertEqual(data, [0x00])
    }
    
    func test_encode_shouldReturnOne_givenTrue() {
        let value: Bool = true
        let data = [UInt8](value.data())
        XCTAssertEqual(data, [0x01])
    }
    
    // MARK: Decode
    
    func test_decode_shouldReturnFalse_givenZero() throws {
        let data = Data([0x00])
        let value = try Bool(data: data)
        XCTAssertFalse(value)
    }
    
    func test_decode_shouldReturnTrue_givenOne() throws {
        let data = Data([0x01])
        let value = try Bool(data: data)
        XCTAssertTrue(value)
    }
    
    func test_decode_shouldReturnTrue_givenNonZero() throws {
        for i in 1 ..< 256 {
            let data = Data([UInt8(i)])
            let value = try Bool(data: data)
            XCTAssertTrue(value)
        }
    }
}

///
/// Copright (c) 2022 Luke Van In
///
import XCTest

@testable import SwiftPack

final class OptionalDataCodableTests: XCTestCase {
    
    // MARK: Encode
    
    func test_encode_shouldReturnFalse_givenNil() {
        let value: Optional<UInt8> = .none
        let data = [UInt8](value.data())
        XCTAssertEqual(data, [0x00])
    }
    
    func test_encode_shouldReturnValue_givenValue() {
        let value: Optional<UInt8> = .some(0x07)
        let data = [UInt8](value.data())
        XCTAssertEqual(data, [0x01, 0x07])
    }
    
    // MARK: Decode
    
    func test_decode_shouldReturnNil_givenFalse() throws {
        let data = Data([0x00])
        let value = try Optional<UInt8>(data: data)
        XCTAssertEqual(value, .none)
    }
    
    func test_decode_shouldReturnValue_givenValue() throws {
        let data = Data([0x01, 0x07])
        let value = try Optional<UInt8>(data: data)
        XCTAssertEqual(value, .some(0x07))
    }
}

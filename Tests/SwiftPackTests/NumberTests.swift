///
/// Copright (c) 2022 Luke Van In
///
import XCTest

@testable import SwiftPack

final class IntegerDataCodableTests: XCTestCase {
    
    // MARK: - Data encoder
    
    func testDataEncoder_writeUInt8() {
        let element = UInt8(0x81) // 1000 0001
        let data = element.data()
        XCTAssertEqual([UInt8](data), [0x81])
    }
    
    func testDataEncoder_writeInt8() {
        let element = Int8(0x18) // 0001 1000
        let data = element.data()
        XCTAssertEqual([UInt8](data), [0x18])
    }

    func testDataEncoder_writeUInt16() {
        let element = UInt16(0x8142) // 1000 0001 0100 0010
        let data = element.data()
        XCTAssertEqual([UInt8](data), [0x81, 0x42])
    }

    func testDataEncoder_writeInt16() {
        let element = Int16(0x4281) // 0100 0010 1000 0001
        let data = element.data()
        XCTAssertEqual([UInt8](data), [0x42, 0x81])
    }

    func testDataEncoder_writeUInt32() {
        let element = UInt32(0x8142c33c) // 1000 0001 0001 1000 1100 0011 0011 1100
        let data = element.data()
        XCTAssertEqual([UInt8](data), [0x81, 0x42, 0xc3, 0x3c])
    }

    func testDataEncoder_writeInt32() {
        let element = Int32(0x4281c33c) // 0001 1000 1000 0001 1100 0011 0011 1100
        let data = element.data()
        XCTAssertEqual([UInt8](data), [0x42, 0x81, 0xc3, 0x3c])
    }

    func testDataEncoder_writeUInt64() {
        let element = UInt64(0x8142c33cc33c4281)
        let data = element.data()
        XCTAssertEqual([UInt8](data), [0x81, 0x42, 0xc3, 0x3c, 0xc3, 0x3c, 0x42, 0x81])
    }

    func testDataEncoder_writeInt64() {
        let element = Int64(0x42c33cc33c814281)
        let data = element.data()
        XCTAssertEqual([UInt8](data),  [0x42, 0xc3, 0x3c, 0xc3, 0x3c, 0x81, 0x42, 0x81])
    }

    func testDataEncoder_writeFloat32() {
        let element = Float32(bitPattern: 0x8142c33c) // 1000 0001 0001 1000 1100 0011 0011 1100
        let data = element.data()
        XCTAssertEqual([UInt8](data), [0x81, 0x42, 0xc3, 0x3c])
    }

    func testDataEncoder_writeFloat64() {
        let element = Float64(bitPattern: 0x8142c33cc33c4281) // 1100 0011 0011 1100 0001 1000 1000 0001 1100 0011 0011 1100 0001 1000 1000 0001
        let data = element.data()
        XCTAssertEqual([UInt8](data),  [0x81, 0x42, 0xc3, 0x3c, 0xc3, 0x3c, 0x42, 0x81])
    }


    // MARK: - Data decoder
    
    func testDataDecoder_readUInt8() throws {
        let data = Data([0x81]) // 1000 0001
        let element = try UInt8(data: data)
        XCTAssertEqual(element, UInt8(0x81))
    }
    
    func testDataDecoder_readInt8() throws {
        let data = Data([0x18])
        let element = try Int8(data: data)
        XCTAssertEqual(element, Int8(0x18)) // 0001 1000
    }

    func testDataDecoder_readUInt16() throws {
        let data = Data([0x81, 0x42])
        let element = try UInt16(data: data)
        XCTAssertEqual(element, UInt16(0x8142)) // 1000 0001 0100 0010
    }

    func testDataDecoder_readInt16() throws {
        let data = Data([0x42, 0x81])
        let element = try Int16(data: data)
        XCTAssertEqual(element, Int16(0x4281)) // 0100 0010 1000 0001
    }

    func testDataDecoder_readUInt32() throws {
        let data = Data([0x81, 0x42, 0xc3, 0x3c])
        let element = try UInt32(data: data)
        XCTAssertEqual(element, UInt32(0x8142c33c)) // 1000 0001 0001 1000 1100 0011 0011 1100
    }

    func testDataDecoder_readInt32() throws {
        let data = Data([0x42, 0x81, 0xc3, 0x3c])
        let element = try Int32(data: data)
        XCTAssertEqual(element,  Int32(0x4281c33c)) // 0001 1000 1000 0001 1100 0011 0011 1100
    }

    func testDataDecoder_readUInt64() throws {
        let data = Data([0x81, 0x42, 0xc3, 0x3c, 0xc3, 0x3c, 0x42, 0x81])
        let element = try UInt64(data: data)
        XCTAssertEqual(element,  UInt64(0x8142c33cc33c4281))
    }

    func testDataDecoder_readInt64() throws {
        let data = Data([0x42, 0xc3, 0x3c, 0xc3, 0x3c, 0x81, 0x42, 0x81])
        let element = try Int64(data: data)
        XCTAssertEqual(element,  Int64(0x42c33cc33c814281))
    }

    func testDataDecoder_readFloat32() throws {
        let data = Data([0x81, 0x42, 0xc3, 0x3c])
        let element = try Float32(data: data)
        XCTAssertEqual(element,  Float32(bitPattern: 0x8142c33c)) // 1000 0001 0001 1000 1100 0011 0011 1100
    }

    func testDataDecoder_readFloat64() throws {
        let data = Data([0x81, 0x42, 0xc3, 0x3c, 0xc3, 0x3c, 0x42, 0x81])
        let element = try Float64(data: data)
        XCTAssertEqual(element,  Float64(bitPattern: 0x8142c33cc33c4281)) // 1100 0011 0011 1100 0001 1000 1000 0001 1100 0011 0011 1100 0001 1000 1000 0001
    }

}

///
/// Copright (c) 2022 Luke Van In
///
import XCTest

@testable import SwiftPack

final class VarUInt64Tests: XCTestCase {
    
    // MARK: Write
    
    func testDataEncoder_writeVarUInt64_oneByteLowerLimit() {
        let value = VarUInt64(0x00)
        let data = value.data()
        XCTAssertEqual([UInt8](data), [0x00])
    }

    func testDataEncoder_writeVarUInt64_oneByteUpperLimit() {
        let value = VarUInt64(0x3f)
        let data = value.data()
        XCTAssertEqual([UInt8](data), [0x3f])
    }
    
    func testDataEncoder_writeVarUInt64_twoBytesLowerLimit() {
        let value = VarUInt64(0x40)
        let data = value.data()
        XCTAssertEqual([UInt8](data), [0x40, 0x00])
    }
    
    func testDataEncoder_writeVarUInt64_twoBytesUpperLimit() {
        let value = VarUInt64(0x3fff + 0x40)
        let data = value.data()
        XCTAssertEqual([UInt8](data), [0x7f, 0xff])
    }
    
    func testDataEncoder_writeVarUInt64_fourBytesLowerLimit() {
        let value = VarUInt64(0x3fff + 0x41)
        let data = value.data()
        XCTAssertEqual([UInt8](data), [0x80, 0x00, 0x00, 0x00])
    }
    
    func testDataEncoder_writeVarUInt64_fourBytesUpperLimit() {
        let value = VarUInt64(0x3fffffff + 0x4000 + 0x40)
        let data = value.data()
        XCTAssertEqual([UInt8](data), [0xbf, 0xff, 0xff, 0xff])
    }
    
    func testDataEncoder_writeVarUInt64_eightBytesLowerLimit() {
        let value = VarUInt64(0x3fffffff + 0x4000 + 0x41)
        let data = value.data()
        XCTAssertEqual([UInt8](data), [0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    }
    
    func testDataEncoder_writeVarUInt64_eightBytesUpperLimit() {
        let value = VarUInt64(0x3fffffffffffffff + 0x40000000 + 0x4000 + 0x40)
        let data = value.data()
        XCTAssertEqual([UInt8](data), [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
    }
    
    // MARK: Read
    
    func testInit_oneByteLowerLimit() throws {
        let data = Data([0x00])
        let value = try VarUInt64(data: data)
        XCTAssertEqual(value, VarUInt64(0x00))
    }

    func testInit_oneByteUpperLimit() throws {
        let data = Data([0x3f])
        let value = try VarUInt64(data: data)
        XCTAssertEqual(value, VarUInt64(0x3f))
    }
    
    func testInit_twoBytesLowerLimit() throws {
        let data = Data([0x40, 0x00])
        let value = try VarUInt64(data: data)
        XCTAssertEqual(value, VarUInt64(0x0040))
    }
    
    func testInit_twoBytesUpperLimit() throws {
        let data = Data([0x7f, 0xff]) // 32767
        let value = try VarUInt64(data: data)
        XCTAssertEqual(value, VarUInt64(0x3fff + 0x40)) // 16447
    }
    
    func testInit_fourBytesLowerLimit() throws {
        let data = Data([0x80, 0x00, 0x00, 0x00])
        let value = try VarUInt64(data: data)
        XCTAssertEqual(value, VarUInt64(0x3fff + 0x41))
    }
    
    func testInit_fourBytesUpperLimit() throws {
        let data = Data([0xbf, 0xff, 0xff, 0xff])
        let value = try VarUInt64(data: data)
        XCTAssertEqual(value, VarUInt64(0x3fffffff + 0x4000 + 0x40))
    }
    
    func testInit_eightBytesLowerLimit() throws {
        let data = Data([0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        let value = try VarUInt64(data: data)
        XCTAssertEqual(value, VarUInt64(0x3fffffff + 0x4000 + 0x41))
    }
    
    func testInit_eightBytesUpperLimit() throws {
        let data = Data([0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
        let value = try VarUInt64(data: data)
        XCTAssertEqual(value, VarUInt64(0x3fffffffffffffff + 0x40000000 + 0x4000 + 0x40))
    }
    
}

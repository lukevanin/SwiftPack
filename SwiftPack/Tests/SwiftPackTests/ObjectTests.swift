///
/// Copright (c) 2022 Luke Van In
///
import XCTest

@testable import SwiftPack


private struct Sample: Equatable {
    var value: UInt8
}

extension Sample: DataCodable {
    
    init(decoder: DataDecoder) throws {
        self.value = try decoder.readUInt8()
    }
    
    func encode(encoder: DataEncoder) {
        encoder.writeUInt8(value)
    }
}


private struct NestedSample: Equatable {
    var value: UInt8
    var nestedValue: Sample
}

extension NestedSample: DataCodable {
    
    init(decoder: DataDecoder) throws {
        self.value = try UInt8(decoder: decoder)
        self.nestedValue = try Sample(decoder: decoder)
    }
    
    func encode(encoder: DataEncoder) {
        value.encode(encoder: encoder)
        nestedValue.encode(encoder: encoder)
    }
}


final class CustomTests: XCTestCase {
    
    // MARK: Simple
    
    func testSimpleEncode() {
        let sample = Sample(value: 0x81)
        let data = sample.data()
        XCTAssertEqual(data, Data([0x81]))
    }
    
    func testSimpleDecode() throws {
        let expected = Sample(value: 0x81)
        let data = Data([0x81])
        let sample = try Sample(data: data)
        XCTAssertEqual(sample, expected)
    }
    
    // MARK: Nested
    
    func testNestedEncode() {
        let sample = NestedSample(value: 0x77, nestedValue: Sample(value: 0x81))
        let data = sample.data()
        XCTAssertEqual(data, Data([0x77, 0x81]))
    }
    
    func testNestedDecode() throws {
        let expected = NestedSample(value: 0x77, nestedValue: Sample(value: 0x81))
        let data = Data([0x77, 0x81])
        let sample = try NestedSample(data: data)
        XCTAssertEqual(sample, expected)
    }
}

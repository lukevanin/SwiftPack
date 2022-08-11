///
/// Copright (c) 2022 Luke Van In
///
import Foundation


extension UInt8: DataCodable {
    public func encode(encoder: DataEncoder) {
        encoder.writeUInt8(self)
    }
    
    public init(decoder: DataDecoder) throws {
        self = try decoder.readUInt8()
    }
}


extension Int8: DataCodable {
    public init(decoder: DataDecoder) throws {
        let unsigned = try decoder.readUInt8()
        self.init(bitPattern: unsigned)
    }
    
    public func encode(encoder: DataEncoder) {
        let unsigned = UInt8(bitPattern: self)
        encoder.writeUInt8(unsigned)
    }
}


extension UInt16: DataCodable {
    public func encode(encoder: DataEncoder) {
        encoder.writeUInt16(self)
    }
    
    public init(decoder: DataDecoder) throws {
        self = try decoder.readUInt16()
    }
}


extension Int16: DataCodable {
    public init(decoder: DataDecoder) throws {
        let unsigned = try decoder.readUInt16()
        self.init(bitPattern: unsigned)
    }
    
    public func encode(encoder: DataEncoder) {
        let unsigned = UInt16(bitPattern: self)
        encoder.writeUInt16(unsigned)
    }
}


extension UInt32: DataCodable {
    public func encode(encoder: DataEncoder) {
        encoder.writeUInt32(self)
    }
    
    public init(decoder: DataDecoder) throws {
        self = try decoder.readUInt32()
    }
}


extension Int32: DataCodable {
    public init(decoder: DataDecoder) throws {
        let unsigned = try decoder.readUInt32()
        self.init(bitPattern: unsigned)
    }
    
    public func encode(encoder: DataEncoder) {
        let unsigned = UInt32(bitPattern: self)
        encoder.writeUInt32(unsigned)
    }
}


extension UInt64: DataCodable {
    public func encode(encoder: DataEncoder) {
        encoder.writeUInt64(self)
    }
    
    public init(decoder: DataDecoder) throws {
        self = try decoder.readUInt64()
    }
}


extension Int64: DataCodable {
    public init(decoder: DataDecoder) throws {
        let unsigned = try decoder.readUInt64()
        self.init(bitPattern: unsigned)
    }
    
    public func encode(encoder: DataEncoder) {
        let unsigned = UInt64(bitPattern: self)
        encoder.writeUInt64(unsigned)
    }
}


public struct VarUInt64: DataCodable, Equatable {
    
    public let value: UInt64
    
    public init<T>(_ value: T) where T: BinaryInteger {
        self.value = UInt64(value)
    }
    
    public init(decoder: DataDecoder) throws {
        self.value = try decoder.readVarUInt64()
    }
    
    public func encode(encoder: DataEncoder) {
        encoder.writeVarUInt64(value)
    }
}

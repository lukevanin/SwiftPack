///
/// Copright (c) 2022 Luke Van In
///
import Foundation


extension UInt8: DataCodable {
    func encode(encoder: DataEncoder) {
        encoder.writeUInt8(self)
    }
    
    init(decoder: DataDecoder) throws {
        self = try decoder.readUInt8()
    }
}


extension Int8: DataCodable {
    init(decoder: DataDecoder) throws {
        let unsigned = try decoder.readUInt8()
        self.init(bitPattern: unsigned)
    }
    
    func encode(encoder: DataEncoder) {
        let unsigned = UInt8(bitPattern: self)
        encoder.writeUInt8(unsigned)
    }
}


extension UInt16: DataCodable {
    func encode(encoder: DataEncoder) {
        encoder.writeUInt16(self)
    }
    
    init(decoder: DataDecoder) throws {
        self = try decoder.readUInt16()
    }
}


extension Int16: DataCodable {
    init(decoder: DataDecoder) throws {
        let unsigned = try decoder.readUInt16()
        self.init(bitPattern: unsigned)
    }
    
    func encode(encoder: DataEncoder) {
        let unsigned = UInt16(bitPattern: self)
        encoder.writeUInt16(unsigned)
    }
}


extension UInt32: DataCodable {
    func encode(encoder: DataEncoder) {
        encoder.writeUInt32(self)
    }
    
    init(decoder: DataDecoder) throws {
        self = try decoder.readUInt32()
    }
}


extension Int32: DataCodable {
    init(decoder: DataDecoder) throws {
        let unsigned = try decoder.readUInt32()
        self.init(bitPattern: unsigned)
    }
    
    func encode(encoder: DataEncoder) {
        let unsigned = UInt32(bitPattern: self)
        encoder.writeUInt32(unsigned)
    }
}


extension UInt64: DataCodable {
    func encode(encoder: DataEncoder) {
        encoder.writeUInt64(self)
    }
    
    init(decoder: DataDecoder) throws {
        self = try decoder.readUInt64()
    }
}


extension Int64: DataCodable {
    init(decoder: DataDecoder) throws {
        let unsigned = try decoder.readUInt64()
        self.init(bitPattern: unsigned)
    }
    
    func encode(encoder: DataEncoder) {
        let unsigned = UInt64(bitPattern: self)
        encoder.writeUInt64(unsigned)
    }
}


struct VarUInt64: DataCodable, Equatable {
    
    let value: UInt64
    
    init<T>(_ value: T) where T: BinaryInteger {
        self.value = UInt64(value)
    }
    
    init(decoder: DataDecoder) throws {
        self.value = try decoder.readVarUInt64()
    }
    
    func encode(encoder: DataEncoder) {
        encoder.writeVarUInt64(value)
    }
}

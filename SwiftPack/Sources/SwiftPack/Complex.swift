///
/// Copright (c) 2022 Luke Van In
///
import Foundation


extension Bool: DataCodable {
    func encode(encoder: DataEncoder) {
        let value: UInt8 = self ? 1 : 0
        value.encode(encoder: encoder)
    }
    
    init(decoder: DataDecoder) throws {
        let value = try UInt8(decoder: decoder)
        self = (value == 0) ? false : true
    }
}


extension Optional: DataCodable where Wrapped: DataCodable {
    init(decoder: DataDecoder) throws {
        let isNil = try Bool(decoder: decoder)
        switch isNil {
        case false:
            self = .none
        case true:
            self = .some(try Wrapped(decoder: decoder))
        }
    }
    
    func encode(encoder: DataEncoder) {
        switch self {
        case .none:
            false.encode(encoder: encoder)
        case .some(let value):
            true.encode(encoder: encoder)
            value.encode(encoder: encoder)
        }
    }
}


extension String: DataCodable {
    
    init(decoder: DataDecoder) throws {
        let data = try Data(decoder: decoder)
        #warning("TODO: unsafe unwrap")
        self.init(data: data, encoding: .utf8)!
    }
    
    func encode(encoder: DataEncoder) {
        #warning("TODO: unsafe unwrap")
        let values = data(using: .utf8)!
        values.encode(encoder: encoder)
    }
}


extension Data: DataCodable {
    init(decoder: DataDecoder) throws {
        let count = try VarUInt64(decoder: decoder)
        self = try decoder.readBytes(count: Int(count.value))
    }
    
    func encode(encoder: DataEncoder) {
        VarUInt64(count).encode(encoder: encoder)
        encoder.writeBytes(self)
    }
}



extension Array: DataCodable where Element: DataCodable {
    init(decoder: DataDecoder) throws {
        let count = try VarUInt64(decoder: decoder)
        var elements = [Element]()
        for _ in 0 ..< count.value {
            let element = try Element(decoder: decoder)
            elements.append(element)
        }
        self = elements
    }
    
    func encode(encoder: DataEncoder) {
        VarUInt64(count).encode(encoder: encoder)
        for element in self {
            element.encode(encoder: encoder)
        }
    }
}


extension Dictionary: DataCodable where Key: DataCodable & Hashable & Comparable, Value: DataCodable {
    init(decoder: DataDecoder) throws {
        let count = try VarUInt64(decoder: decoder)
        var elements = [Key: Value]()
        for _ in 0 ..< count.value {
            let key = try Key(decoder: decoder)
            let value = try Value(decoder: decoder)
            elements[key] = value
        }
        self = elements
    }
    
    func encode(encoder: DataEncoder) {
        VarUInt64(count).encode(encoder: encoder)
        for key in keys.sorted() {
            let value = self[key]!
            key.encode(encoder: encoder)
            value.encode(encoder: encoder)
        }
    }
}

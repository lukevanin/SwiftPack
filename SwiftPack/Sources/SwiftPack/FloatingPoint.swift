///
/// Copright (c) 2022 Luke Van In
///
import Foundation


extension Float32: DataCodable {
    init(decoder: DataDecoder) throws {
        let bits = try decoder.readUInt32()
        self.init(bitPattern: bits)
    }
    
    func encode(encoder: DataEncoder) {
        encoder.writeUInt32(bitPattern)
    }
}


extension Float64: DataCodable {
    init(decoder: DataDecoder) throws {
        let bits = try decoder.readUInt64()
        self.init(bitPattern: bits)
    }
    
    func encode(encoder: DataEncoder) {
        encoder.writeUInt64(bitPattern)
    }
}


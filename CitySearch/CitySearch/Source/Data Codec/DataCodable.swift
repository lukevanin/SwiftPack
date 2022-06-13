import Foundation


protocol DataCodable{
    init(decoder: DataDecoder) throws
    func encode(encoder: DataEncoder)
}

extension DataCodable {
    init(data: Data) throws {
        let decoder = DataDecoder(data: data)
        try self.init(decoder: decoder)
    }
    
    func data() -> Data {
        let measureEncoder = DataEncoder(capacity: nil)
        encode(encoder: measureEncoder)
        let encoder = DataEncoder(capacity: measureEncoder.count)
        encode(encoder: encoder)
        let data = Data(buffer: encoder.data!)
        return data
    }
    
    init(fileURL: URL) throws {
        let compressedData = try Data(contentsOf: fileURL, options: [.uncached])
        let data = NSMutableData(data: compressedData)
        try data.decompress(using: .lzfse)
        let decoder = DataDecoder(data: data as Data)
        try self.init(decoder: decoder)
    }
    
    func write(to fileURL: URL) throws {
        let measureEncoder = DataEncoder(capacity: nil)
        encode(encoder: measureEncoder)
        let encoder = DataEncoder(capacity: measureEncoder.count)
        encode(encoder: encoder)
        let uncompressedData = encoder.data!
        let data = NSMutableData(bytes: uncompressedData.baseAddress, length: encoder.count)
        try data.compress(using: .lzfse)
        try data.write(to: fileURL, options: [.atomic])
    }
}

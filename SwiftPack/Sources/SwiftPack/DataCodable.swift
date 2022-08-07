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
        let rawData = try Data(contentsOf: fileURL, options: [.uncached])
//        let data = NSData(data: compressedData)
//        let decompressedData = try data.decompressed(using: .lz4) as Data
//        let decoder = DataDecoder(data: decompressedData)
        let decoder = DataDecoder(data: rawData)
        try self.init(decoder: decoder)
    }
    
    func write(to fileURL: URL) throws {
        let measureEncoder = DataEncoder(capacity: nil)
        encode(encoder: measureEncoder)
        let encoder = DataEncoder(capacity: measureEncoder.count)
        encode(encoder: encoder)
        let rawData = NSData(bytes: encoder.data!.baseAddress, length: encoder.count)
//        let compressedData =  try data.compressed(using: .lz4)
//        try compressedData.write(to: fileURL, options: [.atomic])
        try rawData.write(to: fileURL, options: [.atomic])
    }
}

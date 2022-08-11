///
/// Copright (c) 2022 Luke Van In
///
import Foundation


public protocol DataCodable{
    init(decoder: DataDecoder) throws
    func encode(encoder: DataEncoder)
}

extension DataCodable {
    public init(data: Data) throws {
        let decoder = DataDecoder(data: data)
        try self.init(decoder: decoder)
    }
    
    public func data() -> Data {
        let measureEncoder = DataEncoder(capacity: nil)
        encode(encoder: measureEncoder)
        let encoder = DataEncoder(capacity: measureEncoder.count)
        encode(encoder: encoder)
        let data = Data(buffer: encoder.data!)
        return data
    }
    
    public init(fileURL: URL) throws {
        let rawData = try Data(contentsOf: fileURL, options: [.uncached])
        let decoder = DataDecoder(data: rawData)
        try self.init(decoder: decoder)
    }
    
    public func write(to fileURL: URL) throws {
        let measureEncoder = DataEncoder(capacity: nil)
        encode(encoder: measureEncoder)
        let encoder = DataEncoder(capacity: measureEncoder.count)
        encode(encoder: encoder)
        let rawData = NSData(bytes: encoder.data!.baseAddress, length: encoder.count)
        try rawData.write(to: fileURL, options: [.atomic])
    }
}

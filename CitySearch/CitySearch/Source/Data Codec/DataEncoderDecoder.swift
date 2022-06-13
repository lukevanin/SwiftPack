import Foundation

private let byte1: UInt64 = 0x40
private let byte2: UInt64 = 0x4040
private let byte4: UInt64 = 0x40004040
private let byte8: UInt64 = 0x4000000040004040

private let mask1: UInt64 = 0x3f
private let mask2: UInt64 = 0x3fff
private let mask4: UInt64 = 0x3fffffff
private let mask8: UInt64 = 0x3fffffffffffffff

private let flag2: UInt64 = 0x4000
private let flag4: UInt64 = 0x80000000
private let flag8: UInt64 = 0xc000000000000000

class DataEncoder {
    
    private(set) var count = 0
    private(set) var data: UnsafeMutableBufferPointer<UInt8>?
    private var current: UnsafeMutablePointer<UInt8>?
    private var rawPointer: UnsafeMutableRawPointer?

    init(capacity: Int?) {
        if let capacity = capacity {
            self.data = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: capacity)
            self.current = data?.baseAddress
            self.rawPointer = UnsafeMutableRawPointer(self.current)
        }
    }
    
    deinit {
        data?.deallocate()
    }
    
    func writeBytes(_ bytes: Data) {
        if let current = current {
            bytes.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) -> Void in
                let pointer = buffer.bindMemory(to: UInt8.self)
                current.advanced(by: count).assign(from: pointer.baseAddress!, count: bytes.count)
            }
        }
        count += bytes.count
    }
    
    func writeVarUInt64(_ value: UInt64) {
        if value < byte1 {
            // 8 bits
            let output = UInt8(value)
            writeUInt8(output)
        }
        else if value < byte2 {
            // 16  bits
            let prefix = UInt16(flag2)
            let output = UInt16(value - byte1)
            writeUInt16(prefix | output)
        }
        else if value < byte4 {
            // 32 bits
            let prefix = UInt32(flag4)
            let output = UInt32(value - byte2)
            writeUInt32(prefix | output)
        }
        else if value < byte8 {
            // 64 bits
            let prefix = UInt64(flag8)
            let output = UInt64(value - byte4)
            writeUInt64(prefix | output)
        }
        else {
            fatalError("overflow")
        }
    }

    func writeUInt8(_ value: UInt8) {
        if let current = current {
            current.advanced(by: count).pointee = value
        }
        count += 1
    }
    
    func writeUInt16(_ value: UInt16) {
        writeBytes(value)
    }

    func writeUInt32(_ value: UInt32) {
        writeBytes(value)
    }
    
    func writeUInt64(_ value: UInt64) {
        writeBytes(value)
    }
    
    private func writeBytes<T>(_ value: T) where T: FixedWidthInteger {
        let size = MemoryLayout<T>.size
        if let rawPointer = rawPointer {
            rawPointer.advanced(by: count).bindMemory(to: T.self, capacity: 1).pointee = value.byteSwapped
        }
        count += size
    }
}


class DataDecoder {
    
    private var index: Int = 0
    private let data: UnsafeMutableBufferPointer<UInt8>
    private let pointer: UnsafeMutablePointer<UInt8>
    private let rawPointer: UnsafeMutableRawPointer
    
    init(data: Data) {
        self.data = UnsafeMutableBufferPointer.allocate(capacity: data.count)
        let _ = data.copyBytes(to: self.data)
        self.pointer = self.data.baseAddress!
        self.rawPointer = UnsafeMutableRawPointer(self.pointer)
    }

    func readBytes(count: Int) throws -> Data {
        #warning("TODO: Check index in range")
        defer {
            index += count
        }
        return Data(bytes: pointer.advanced(by: index), count: count)
    }
    
    func readVarUInt64() throws -> UInt64 {
        let b = pointer.advanced(by: index).pointee
        // 2 to raised to the power of the value in the top two bits indicates
        // the number of bytes:
        // 00 = 0 = 1 byte (8 bits)
        // 01 = 1 = 2 bytes (16 bits)
        // 10 = 2 = 4 bytes (32 bits)
        // 11 = 3 = 8 bytes (64 bits)
        let value = UInt64(b) & mask1
        let exponent = (b >> 6) & 0x03
        switch exponent {
        case 0:
            let bytes = try readUInt8()
            let value = UInt64(bytes) & mask1
            return value
        case 1:
            // 2 bytes
            let bytes = try readUInt16()
            let value = (UInt64(bytes) & mask2) + byte1
            return value
        case 2:
            // 4 bytes
            let bytes = try readUInt32()
            let value = (UInt64(bytes) & mask4) + byte2
            return value
        case 3:
            let bytes = try readUInt64()
            let value = (UInt64(bytes) & mask8) + byte4
            return value
        default:
            fatalError("overflow")
        }
    }
    
    func readUInt8() throws -> UInt8 {
        defer {
            index += 1
        }
        #warning("TODO: Check index in range")
        return pointer.advanced(by: index).pointee
    }

    func readUInt16() throws -> UInt16 {
        try readBytes(UInt16.self)
    }

    func readUInt32() throws -> UInt32 {
        try readBytes(UInt32.self)
    }
    
    func readUInt64() throws -> UInt64 {
        try readBytes(UInt64.self)
    }
    
    private func readBytes<T>(_ type: T.Type) throws -> T where T: FixedWidthInteger {
        #warning("TODO: Check index + size is in range")
        let size = MemoryLayout<T>.size
        defer {
            index += size
        }
        return rawPointer.advanced(by: index).bindMemory(to: T.self, capacity: 1).pointee.byteSwapped
    }
}


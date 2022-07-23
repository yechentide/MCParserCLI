import Foundation

extension Data {
    var hexString: String {
        var result: [String] = []
        for byte in self {
            let hexString = String(format: "%02X", byte)
            result.append(hexString)
        }
        return "0x" + result.joined(separator: "_")
    }
    
    var uint8: UInt8 {
        UInt8(littleEndian: self[ self.startIndex...self.startIndex ].withUnsafeBytes{
            $0.load(as: UInt8.self)
        })
    }
    
    var int8: Int8 {
        Int8(littleEndian: self[ self.startIndex...self.startIndex ].withUnsafeBytes{
            $0.load(as: Int8.self)
        })
    }
    
    var int32: Int32 {
        Int32(littleEndian: self[ self.startIndex+0...self.startIndex+3 ].withUnsafeBytes{
            $0.load(as: Int32.self)
        })
    }
}

extension FixedWidthInteger {
    var data: Data {
        return withUnsafeBytes(of: self) { Data($0) }
    }
    
    var binaryString: String {
        var result: [String] = []
        for i in 0..<(Self.bitWidth / 8) {
            let byte = UInt8(truncatingIfNeeded: self >> (i * 8))
            let byteString = String(byte, radix: 2)
            let padding = String(repeating: "0", count: 8 - byteString.count)
            result.append(padding + byteString)
        }
        return "0b" + result.joined(separator: "_")
    }
    
    mutating func bitOn(offset: UInt8) {
        guard (0..<Self.bitWidth).contains(Int(offset)) else { return }
        let newValue = (self >> offset | 0x1) << offset | self
        self = newValue
    }
    
    mutating func bitOff(offset: UInt8) {
        guard (0..<Self.bitWidth).contains(Int(offset)) else { return }
        let left  = (self >> (offset + 1)) << (offset + 1)
        let n = UInt8(MemoryLayout.size(ofValue: self) * 8)
        let right = (self << (n-offset)) >> (n-offset)
        self = left | right
    }
    
    func isBitOn(offset: UInt8) -> Bool {
        return (self >> offset) & 0x1 == 1
    }
    
    var bitArray: [UInt8] {
        // 0b0010 ---> [0b0, 0b1, 0b0, 0b0]
        var array = [UInt8]()
        for offset in 0..<self.bitWidth {
            let flag = (self >> offset) & 0x1 == 1
            array.append(flag ? 1 : 0)
        }
        return array
    }
}

extension String {
    // string is little endian
    var hexData: Data? {
        var str = self
        if str.hasPrefix("0x") {
            let i = str.index(str.startIndex, offsetBy: 2)
            str = String(str[i...])
        }
        if str.contains("_") {
            str = str.filter { $0 != "_" }
        }
        guard str.count % 2 == 0 else { return nil }
        
        var byteArray = [UInt8]()
        var start = str.startIndex
        while start < str.endIndex {
            let end = str.index(start, offsetBy: 1)
            let byteStr = str[start...end]
            guard let byte = UInt8(byteStr, radix: 16) else { return nil }
            byteArray.append(byte)
            start = str.index(start, offsetBy: 2)
        }
        return Data(byteArray)
    }
}

extension Date {
    static func generateCurrentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyyMMdd-HHmm"
        
        return formatter.string(from: Date())
    }
}

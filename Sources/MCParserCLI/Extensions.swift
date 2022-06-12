//
//  File.swift
//  
//
//  Created by yechentide on 2022/06/10.
//

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
}

extension String {
    // string is little endian
    var hexData: Data? {
        var byteArray = [UInt8]()
        for c in self {
            guard let byte = UInt8(String(c), radix: 16) else { return nil }
            byteArray.append(byte)
        }
        return Data(byteArray.reversed())
    }
}

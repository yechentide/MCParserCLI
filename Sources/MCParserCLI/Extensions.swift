//
//  File.swift
//  
//
//  Created by yechentide on 2022/06/10.
//

import Foundation

extension Data {
    var hexString: String {
        var hexStr = ""
        for byte in self {
            hexStr += String(format: "%02X", byte)
        }
        return hexStr
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
            // ビットの右側から見ていって、UInt8の8bit(1byte)からはみ出た部分はtruncatiteする。
            // 自身のビット長によって8bitづつ右側ビットシフトをして、右端8bitづつUInt8にしている
            let byte = UInt8(truncatingIfNeeded: self >> (i * 8))
            
            // 2進数文字列に変換
            let byteString = String(byte, radix: 2)
            
            // 8桁(8bit)になるように0 padding
            let padding = String(repeating: "0",
                                 count: 8 - byteString.count)
            // 先頭にパディングを足す
            result.append(padding + byteString)
        }
        
        // 右端の8ビットが配列の先頭に入っているが、joined()するときは左端の8bitが配列の先頭に来ていて欲しいのでreversed()している
        return "0b" + result.reversed().joined(separator: "_")
    }
}

extension String {
    var hexData: Data? {
        var data = Data()
        for c in self {
            guard let byte = UInt8(String(c), radix: 16) else { return nil }
            data.append(byte)
        }
        return data
    }
}

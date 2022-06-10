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

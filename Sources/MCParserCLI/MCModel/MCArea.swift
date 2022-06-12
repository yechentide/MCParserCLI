//
//  File.swift
//  
//
//  Created by yechentide on 2022/06/11.
//

import Foundation

protocol MCArea {
    var xIndex: Int32 { get }
    var zIndex: Int32 { get }
    static var length: Int32 { get }
}

//extension MCArea {
//    var xRange: ClosedRange<Int32> {
//        let start = xIndex * Self.length
//        return start...start+Self.length-1
//    }
//    var zRange: ClosedRange<Int32> {
//        let start = zIndex * Self.length
//        return start...start+Self.length-1
//    }
//    static func scal(xPos: Int, zPos: Int) -> (x: Int, z: Int) {
//        let x = floor(Double(xPos) / Double(Self.length))
//        let z = floor(Double(zPos) / Double(Self.length))
//        return (Int(x), Int(z))
//    }
//}

//struct MCRigion: MCArea {
//    static var length: Int32 = 512
//    var xIndex: Int32
//    var zIndex: Int32
//}

struct MCChunk: MCArea {
    static var length: Int32 = 16
    var xIndex: Int32
    var zIndex: Int32
    
    // chunkKeyTypes storage format: 0b xxxx_xxxx_xx00_0000_0000_0000_0000_0000 // 22<-----0
    var types: UInt32       = 0b0000_0000_0000_0000_0000_0000_0000_0000
    
    // World Height = -64 ~ 319; subChunkIndex = -4 ~ 20
    // subChunkIndex storage format: 0b xxxx_xxxx_0000_0000_0000_0000_0000_0000 // 24<-----0
    var subChunks: UInt32   = 0b0000_0000_0000_0000_0000_0000_0000_0000
    
    static let minimumSubChunkIndex: Int8 = -4
    
    static func scalOffsetForSubChunk(index: Int8) -> UInt8 {
        let offset = UInt8(index - minimumSubChunkIndex)
        guard (0..<UInt32.bitWidth).contains(Int(offset)) else {
            fatalError("Error: wrong index for subChunk")
        }
        return offset
    }
    static func scalOffsetForType(type: MCChunkKeyType) -> UInt8 {
        let offset = type.rawValue - MCChunkKeyType.keyTypeStartWith
        guard (0..<UInt32.bitWidth).contains(Int(offset)) else {
            fatalError("Error: wrong key type for subChunk")
        }
        return offset
    }
    
    mutating func addSubChunk(index: Int8) {
        let offset = Self.scalOffsetForSubChunk(index: index)
        self.subChunks.bitOn(offset: offset)
    }
    
    mutating func deleteSubChunk(index: Int8) {
        let offset = Self.scalOffsetForSubChunk(index: index)
        self.subChunks.bitOff(offset: offset)
    }
    
    func hasSubChunk(index: Int8) -> Bool {
        let offset = Self.scalOffsetForSubChunk(index: index)
        return self.subChunks.isBitOn(offset: offset)
    }
    
    func existSubChunks() -> [Int8] {
        var subChunks = [Int8]()
        let bitArray = self.subChunks.bitArray
        for i in 0..<bitArray.count {
            if bitArray[i] == 1 {
                let index = Self.minimumSubChunkIndex + Int8(i)
                subChunks.append(index)
            }
        }
        return subChunks
    }
    
    mutating func addType(type: MCChunkKeyType) {
        types.bitOn(offset: Self.scalOffsetForType(type: type))
    }
    
    mutating func deleteType(type: MCChunkKeyType) {
        types.bitOff(offset: Self.scalOffsetForType(type: type))
    }
    
    func hasType(type: MCChunkKeyType) -> Bool {
        return types.isBitOn(offset: Self.scalOffsetForType(type: type))
    }
    
    func existTypes() -> Set<MCChunkKeyType> {
        var types = Set<MCChunkKeyType>()
        let bitArray = self.types.bitArray
        for i in 0..<bitArray.count {
            if bitArray[i] == 1, let newType = MCChunkKeyType(rawValue: MCChunkKeyType.keyTypeStartWith+UInt8(i)) {
                types.insert(newType)
            }
        }
        return types
    }
}

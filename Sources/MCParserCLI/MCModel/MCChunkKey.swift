import Foundation

struct MCChunkKey: MCArea {
    static var length: Int32 = 16
    var xIndex: Int32
    var zIndex: Int32
    
    /// chunkKeyTypes storage format:
    /// 0b xxxx_xxxx_xx00_0000_0000_0000_0000_0000      // 22<-----0
    var types: UInt32       = 0b0000_0000_0000_0000_0000_0000_0000_0000
    
    /// World Height = -64 ~ 319
    /// subChunkIndex = -4 ~ 20
    /// subChunkIndex storage format:
    /// 0b xxxx_xxxx_0000_0000_0000_0000_0000_0000      // 24<-----0   (20 <-- -4)
    var subChunks: UInt32   = 0b0000_0000_0000_0000_0000_0000_0000_0000
    
    static let minimumSubChunkIndex: Int8 = -4
    
    static func bitOffset(subChunkIndex: Int8) -> UInt8 {
        let offset = UInt8(subChunkIndex - minimumSubChunkIndex)
        guard (0..<UInt32.bitWidth).contains(Int(offset)) else {
            fatalError("Error: wrong index for subChunk")
        }
        return offset
    }
    
    static func bitOffset(chunkKeyType: MCChunkKeyType) -> UInt8 {
        let offset = chunkKeyType.rawValue - MCChunkKeyType.keyTypeStartWith
        guard (0..<UInt32.bitWidth).contains(Int(offset)) else {
            fatalError("Error: wrong key type for subChunk")
        }
        return offset
    }
    
    func generateKeyData(dimension: MCDimension) -> [Data] {
        var keyDataArray = [Data]()
        
        let keyPrefix: Data
        if dimension == .overworld {
           keyPrefix = xIndex.data + zIndex.data
        } else {
            keyPrefix = xIndex.data + zIndex.data + dimension.rawValue.data
        }
        
        for type in existTypes() {
            guard type != .subChunkPrefix else { continue }
            let data = keyPrefix + type.rawValue.data
            keyDataArray.append(data)
        }
        for subChunkIndex in existSubChunks() {
            let data = keyPrefix + MCChunkKeyType.subChunkPrefix.rawValue.data + subChunkIndex.data
            keyDataArray.append(data)
        }
        
        return keyDataArray
    }
}

extension MCChunkKey {
    mutating func addSubChunk(index: Int8) {
        let offset = Self.bitOffset(subChunkIndex: index)
        self.subChunks.bitOn(offset: offset)
    }
    
    mutating func deleteSubChunk(index: Int8) {
        let offset = Self.bitOffset(subChunkIndex: index)
        self.subChunks.bitOff(offset: offset)
    }
    
    mutating func addChunkKeyType(type: MCChunkKeyType) {
        let offset = Self.bitOffset(chunkKeyType: type)
        types.bitOn(offset: offset)
    }
    
    mutating func deleteChunkKeyType(type: MCChunkKeyType) {
        let offset = Self.bitOffset(chunkKeyType: type)
        types.bitOff(offset: offset)
    }
}

extension MCChunkKey {
    func checkExist(subChunkIndex: Int8) -> Bool {
        let offset = Self.bitOffset(subChunkIndex: subChunkIndex)
        return self.subChunks.isBitOn(offset: offset)
    }
    
    func checkExist(chunkKeyType: MCChunkKeyType) -> Bool {
        let offset = Self.bitOffset(chunkKeyType: chunkKeyType)
        return self.types.isBitOn(offset: offset)
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

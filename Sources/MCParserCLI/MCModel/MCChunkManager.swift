//
//  File.swift
//  
//
//  Created by yechentide on 2022/06/11.
//

import Foundation
import LvDBWrapper

@inlinable
func generateMapKey(_ xPos: Int32, _ zPos: Int32) -> String {
    return "\(xPos)_\(zPos)"
}

class MCChunkManager {
    let db: LvDB!
    var overworld: [String:MCChunk] = [:]   // key:   xPos_zPos
    var theNether: [String:MCChunk] = [:]
    var theEnd: [String:MCChunk] = [:]
    
    init?(dbDirPath: String) {
        db = LvDB(dbPath: dbDirPath)
        guard db != nil, let keyDataArray = db.getAllKeys() as? [Data] else {
            return nil
        }
        for keyData in keyDataArray {
            initChunksArray(key: keyData)
        }
    }
    
    func initChunksArray(key: Data) {
        guard [9, 10, 13, 14].contains(key.count) else {
            return
        }
        if let keyStr = String(data: key, encoding: .utf8),
                ["BiomeData", "mobevents", "Overworld", "scoreboard", "~local_player"].contains(keyStr) {
            return
        }
        
        let x = key[0...3].int32
        let z = key[4...7].int32
        var typeIndex = 8
        var dimension = MCDimension.overworld
        if key.count > 10 {
            dimension = MCDimension(rawValue: key[8...11].int32)!
            typeIndex = 12
        }
        
        let chunkType = MCChunkKeyType(rawValue: key[typeIndex])!
        addChunkType(dimension: dimension, xPos: x, zPos: z, type: chunkType)
        
        if chunkType == .subChunkPrefix {
            let subChunkIndex = key[typeIndex+1].data.int8
            addSubChunk(dimension: dimension, xPos: x, zPos: z, subChunkIndex: subChunkIndex)
        }
    }
    
    func addChunkType(dimension: MCDimension, xPos: Int32, zPos: Int32, type: MCChunkKeyType) {
        let mapKey = generateMapKey(xPos, zPos)
        var chunk = MCChunk(xIndex: xPos, zIndex: zPos)
        chunk.addType(type: type)
        
        switch dimension {
        case .overworld:
            if let _ = overworld[mapKey] {
                overworld[mapKey]!.addType(type: type)
            } else {
                overworld[mapKey] = chunk
            }
        case .theNether:
            if let _ = theNether[mapKey] {
                theNether[mapKey]!.addType(type: type)
            } else {
                theNether[mapKey] = chunk
            }
        case .theEnd:
            if let _ = theEnd[mapKey] {
                theEnd[mapKey]!.addType(type: type)
            } else {
                theEnd[mapKey] = chunk
            }
        }
    }
    
    func addSubChunk(dimension: MCDimension, xPos: Int32, zPos: Int32, subChunkIndex: Int8) {
        let mapKey = generateMapKey(xPos, zPos)
        var chunk = MCChunk(xIndex: xPos, zIndex: zPos)
        chunk.addSubChunk(index: subChunkIndex)
        
        switch dimension {
        case .overworld:
            if let _ = overworld[mapKey] {
                overworld[mapKey]!.addSubChunk(index: subChunkIndex)
            } else {
                overworld[mapKey] = chunk
            }
        case .theNether:
            if let _ = theNether[mapKey] {
                theNether[mapKey]!.addSubChunk(index: subChunkIndex)
            } else {
                theNether[mapKey] = chunk
            }
        case .theEnd:
            if let _ = theEnd[mapKey] {
                theEnd[mapKey]!.addSubChunk(index: subChunkIndex)
            } else {
                theEnd[mapKey] = chunk
            }
        }
    }
}

extension MCChunkManager {
    func deleteChunk(dimension: MCDimension, xPos: Int32, zPos: Int32) {
        let mapKey = generateMapKey(xPos, zPos)
        
        switch dimension {
        case .overworld:
            if let _ = overworld[mapKey] {
                deleteChunkFromDB(dimension: dimension, chunk: overworld[mapKey]!)
                overworld[mapKey] = nil
            }
        case .theNether:
            if let _ = theNether[mapKey] {
                deleteChunkFromDB(dimension: dimension, chunk: theNether[mapKey]!)
                theNether[mapKey] = nil
            }
        case .theEnd:
            if let _ = theEnd[mapKey] {
                deleteChunkFromDB(dimension: dimension, chunk: theEnd[mapKey]!)
                theEnd[mapKey] = nil
            }
        }
    }
    
    func deleteChunkFromDB(dimension: MCDimension, chunk: MCChunk) {
        var keyDataArray = [Data]()
        
        let keyPrefix: Data
        if dimension == .overworld {
            keyPrefix = chunk.xIndex.data + chunk.zIndex.data
        } else {
            keyPrefix = chunk.xIndex.data + chunk.zIndex.data + dimension.rawValue.data
        }
        
        let allTypes = chunk.existTypes()
        for cType in allTypes {
            if cType != .subChunkPrefix {
                keyDataArray.append(keyPrefix + Data([cType.rawValue]))
            }
        }
        if allTypes.contains(.subChunkPrefix) {
            for subIndex in chunk.existSubChunks() {
                keyDataArray.append(keyPrefix + Data([MCChunkKeyType.subChunkPrefix.rawValue]) + subIndex.data)
            }
        }
        
        for keyData in keyDataArray {
            let _ = db.deleteValue(keyData)
        }
    }
}

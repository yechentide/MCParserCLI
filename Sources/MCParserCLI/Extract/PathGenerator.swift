//
//  File.swift
//  
//
//  Created by yechentide on 2022/06/10.
//

import Foundation

struct PathGenerator {
    let rootDir: String
    
    private var overworldDir    : String { return rootDir + "chunks/overworld/" }
    private var netherdDir      : String { return rootDir + "chunks/nether/" }
    private var endDir          : String { return rootDir + "chunks/end/" }
    
    private var mapDir          : String { return rootDir + "maps/" }
    private var playerDir       : String { return rootDir + "players/" }
    private var villageDir      : String { return rootDir + "villages/" }
    private var wellKnownDir    : String { return rootDir + "wellKnown/" }
    private var structureDir    : String { return rootDir + "structures/" }
    
    private var actorprefixDir  : String { return rootDir + "actorprefix/" }
    private var digpDir         : String { return rootDir + "digp/" }
    
    init(rootPath: String) {
        rootDir = rootPath.hasSuffix("/") ? rootPath : rootPath+"/"
        
        // check directories
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: rootDir) {
            try? fileManager.createDirectory(atPath: rootDir, withIntermediateDirectories: true)
            
            try? fileManager.createDirectory(atPath: overworldDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: netherdDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: endDir, withIntermediateDirectories: true)
            
            try? fileManager.createDirectory(atPath: mapDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: playerDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: villageDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: wellKnownDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: structureDir, withIntermediateDirectories: true)
            
            try? fileManager.createDirectory(atPath: actorprefixDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: digpDir, withIntermediateDirectories: true)
        }
    }
    
    public func generatePath(key: Data) -> String {
        let keyStr = String(data: key, encoding: .utf8) ?? ""

        switch keyStr {
        case "AutonomousEntities", "BiomeData", "LevelChunkMetaDataDictionary", "mobevents", "Nether", "Overworld", "portals", "schedulerWT", "scoreboard":
            return wellKnownDir + keyStr
        case let str where str.hasPrefix("map_"):
            return mapDir + keyStr
        case let str where str == "~local_player" || str.hasPrefix("player_"):
            return playerDir + keyStr
        case let str where str.hasPrefix("VILLAGE_"):
            return villageDir + keyStr
        case let str where str.hasPrefix("structuretemplate_"):
            return structureDir + keyStr
        case let str where str.hasPrefix("actorprefix"):
            return actorprefixDir + "actorprefix_" + key[11...].hexString
        case let str where str.hasPrefix("digp"):
            return digpDir + "digp_" + key[4...].hexString
        default:
            // digp...
            if let s = String(data: key[0...3], encoding: .utf8), s == "digp" {
                return digpDir + "digp_" + key[4...].hexString
            }
            
            // unknown key
            guard [9, 10, 13, 14].contains(key.count) else {
                return rootDir + key.hexString
            }
            
            // chunk
            return generatePathForChunk(key)
        }
    }
    
    private func generatePathForChunk(_ key: Data) -> String {
        let x = key[0...3].int32
        let z = key[4...7].int32
        var typeIndex = 8
        
        var dimension = MCDimension.overworld
        if key.count > 10 {
            dimension = MCDimension(rawValue: key[8...11].int32)!
            typeIndex = 12
        }
        
        let type = Data([key[typeIndex]]).hexString
        let subChunk = (typeIndex >= key.count - 1) ? "" : "(\(  key[typeIndex+1].data.int8  ))"
        let name = "\(x)_\(z)#\(type)\(subChunk)"
        
        var outputPath = ""
        switch dimension {
        case .overworld:
            outputPath = overworldDir + name
        case .theNether:
            outputPath = netherdDir + name
        case .theEnd:
            outputPath = endDir + name
        }
        
        return outputPath
    }
    
}

//
//  File.swift
//  
//
//  Created by yechentide on 2022/06/10.
//

import Foundation

struct PathGenerator {
    let rootDir: String
    
    private var overworldDir    : String { return self.rootDir + "chunks/overworld/" }
    private var netherdDir      : String { return self.rootDir + "chunks/nether/" }
    private var endDir          : String { return self.rootDir + "chunks/end/" }
    
    private var mapDir          : String { return self.rootDir + "maps/" }
    private var playerDir       : String { return self.rootDir + "players/" }
    private var villageDir      : String { return self.rootDir + "villages/" }
    private var wellKnownDir    : String { return self.rootDir + "wellKnown/" }
    private var structureDir    : String { return self.rootDir + "structures/" }
    
    private var actorprefixDir  : String { return self.rootDir + "actorprefix/" }
    private var digpDir         : String { return self.rootDir + "digp/" }
    
    init(rootPath: String) {
        self.rootDir = rootPath.hasSuffix("/") ? rootPath : rootPath+"/"
        
        // check directories
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: self.rootDir) {
            try? fileManager.createDirectory(atPath: self.rootDir, withIntermediateDirectories: true)
            
            try? fileManager.createDirectory(atPath: self.overworldDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: self.netherdDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: self.endDir, withIntermediateDirectories: true)
            
            try? fileManager.createDirectory(atPath: self.mapDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: self.playerDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: self.villageDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: self.wellKnownDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: self.structureDir, withIntermediateDirectories: true)
            
            try? fileManager.createDirectory(atPath: self.actorprefixDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: self.digpDir, withIntermediateDirectories: true)
        }
    }
    
    public func generatePath(key: Data) -> String {
        let keyStr = String(data: key, encoding: .utf8) ?? ""

        switch keyStr {
        case "AutonomousEntities", "BiomeData", "LevelChunkMetaDataDictionary", "mobevents", "Nether", "Overworld", "portals", "schedulerWT", "scoreboard":
            return self.wellKnownDir + keyStr
        case let str where str.hasPrefix("map_"):
            return self.mapDir + keyStr
        case let str where str == "~local_player" || str.hasPrefix("player_"):
            return self.playerDir + keyStr
        case let str where str.hasPrefix("VILLAGE_"):
            return self.villageDir + keyStr
        case let str where str.hasPrefix("structuretemplate_"):
            return self.structureDir + keyStr
        case let str where str.hasPrefix("actorprefix"):
            return self.actorprefixDir + "actorprefix_" + key[11...].hexString
        case let str where str.hasPrefix("digp"):
            return self.digpDir + "digp_" + key[4...].hexString
        default:
            // digp...
            if let s = String(data: key[0...3], encoding: .utf8), s == "digp" {
                return self.digpDir + "digp_" + key[4...].hexString
            }
            
            // unknown key
            guard [9, 10, 13, 14].contains(key.count) else {
                return self.rootDir + key.hexString
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
        let subChunk = (typeIndex >= key.count - 1) ? "" : "(\(key[typeIndex+1]))"
        let name = "\(x)_\(z)#\(type)\(subChunk)"
        
        var outputPath = ""
        switch dimension {
        case .overworld:
            outputPath = self.overworldDir + name
        case .theNether:
            outputPath = self.netherdDir + name
        case .theEnd:
            outputPath = self.endDir + name
        }
        
        return outputPath
    }
    
}

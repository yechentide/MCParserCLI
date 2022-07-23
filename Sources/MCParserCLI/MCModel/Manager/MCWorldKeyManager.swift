import Foundation
import LvDBWrapper

class MCWorldKeyManager {
    let dirURL: URL
    let db: LvDB
    
    var levelData: LevelData
    
    var chunkManager    = MCChunkKeyManager()
    var wellKnownKeys   = Set<MCWellKnownKey>()
    
    var serverPlayers   = [Data]()
    var maps            = [Data]()
    var villages        = [Data]()
    var structures      = [Data]()
    var actorprefix     = [Data]()
    var digp            = [Data]()
    
    init(dirURL: URL, db: LvDB, levelData: LevelData) {
        self.dirURL = dirURL
        self.db = db
        self.levelData = levelData
        parseAllKeys()
    }
    
    private func parseAllKeys() {
        guard let keyDataArray = db.getAllKeys() as? [Data] else { return }
        for keyData in keyDataArray {
            parseKeyData(keyData)
        }
    }
    
    private func parseKeyData(_ keyData: Data) {
        let keyStr = String(data: keyData, encoding: .utf8) ?? ""
        
        if let wellKnown = MCWellKnownKey(rawValue: keyStr) {
            wellKnownKeys.insert(wellKnown)
            return
        }
        
        switch keyStr {
        case let str where str.hasPrefix("player_"):
            serverPlayers.append(keyData)
            return
        case let str where str.hasPrefix("map_"):
            maps.append(keyData)
            return
        case let str where str.hasPrefix("VILLAGE_"):
            villages.append(keyData)
            return
        case let str where str.hasPrefix("structuretemplate_"):
            structures.append(keyData)
            return
        case let str where str.hasPrefix("actorprefix"):
            actorprefix.append(keyData)
            return
        case let str where str.hasPrefix("digp"):
            digp.append(keyData)
            return
        default:
            // digp...
            if let s = String(data: keyData[0...3], encoding: .utf8), s == "digp" {
                digp.append(keyData)
                return
            }
            
            guard [9, 10, 13, 14].contains(keyData.count) else {
                fatalError("Error: cannot parser key data --> \(keyData.hexString)")
            }
            parserChunkKey(keyData)
        }
    }
    
    private func parserChunkKey(_ keyData: Data) {
        let x = keyData[0...3].int32
        let z = keyData[4...7].int32
        var typeIndex = 8
        
        var dimension = MCDimension.overworld
        if keyData.count > 10 {
            dimension = MCDimension(rawValue: keyData[8...11].int32)!
            typeIndex = 12
        }
        
        let type = MCChunkKeyType(rawValue: keyData[typeIndex])!
        let subChunkIndex: Int8? = (typeIndex >= keyData.count - 1) ? nil : keyData[typeIndex+1].data.int8
        
        chunkManager.addChunk(dimension: dimension, xPos: x, zPos: z, type: type, subChunkIndex: subChunkIndex)
    }
}

extension MCWorldKeyManager {
    func changeWorldName(newName: String) {
        guard newName.count > 0 else { return }
        levelData.worldName = newName
        
        let stringFileURL = dirURL.appendingPathComponent("levelname.txt", isDirectory: false)
        try? newName.write(to: stringFileURL, atomically: true, encoding: .utf8)
        
        let dataFileURL = dirURL.appendingPathComponent("level.dat", isDirectory: false)
        do {
            try FileManager.default.removeItem(at: dataFileURL)
            levelData.save(dstURL: dataFileURL)
        } catch {
            print(error)
        }
    }
    
    func deleteChunk(dimension: MCDimension, xPos: Int32, zPos: Int32) {
        print("Delete: \(dimension)   \(xPos), \(zPos)")
        guard let deletedChunk = chunkManager.deleteChunk(dimension: dimension, xPos: xPos, zPos: zPos) else { return }
        
        for keyData in deletedChunk.generateKeyData(dimension: dimension) {
            let _ = db.deleteValue(keyData)
        }
    }
}

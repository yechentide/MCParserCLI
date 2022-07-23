import Foundation
import LvDBWrapper

struct MCDir: Identifiable {
    var id = UUID()
    
    let dirURL: URL
    let isSecurityScope: Bool
    
    var worldName: String = "Unknown"
    
    static func checkMCDirLegality(dirURL: URL, isSecurityScope: Bool) -> Bool {
        guard !isSecurityScope || dirURL.startAccessingSecurityScopedResource() else { return false }
        defer {
            if isSecurityScope { dirURL.stopAccessingSecurityScopedResource() }
        }
        
        do {
            var (hasDB, hasLevelDat, hasLevelName) = (false, false, false)
            
            let keys : [URLResourceKey] = [.nameKey, .isDirectoryKey]
            let contents = try FileManager.default.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: keys)
            
            for fileURL in contents {
                let attributes = try fileURL.resourceValues(forKeys: Set(keys))
                if attributes.name == "db" && attributes.isDirectory! == true {
                    hasDB = true
                } else if attributes.name == "level.dat" && attributes.isDirectory! == false {
                    hasLevelDat = true
                } else if attributes.name == "levelname.txt" && attributes.isDirectory! == false {
                    hasLevelName = true
                }
            }
            
            if hasDB && hasLevelDat && hasLevelName { return true }
        } catch {
            print(error)
        }
        
        return false
    }
    
    static private func getCurrentTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMdd-HHmmss"
        return dateFormatter.string(from: Date())
    }
    
#if DEBUG
    init() {
        self.dirURL = URL(fileURLWithPath: "./debug")
        self.isSecurityScope = false
        self.worldName = "world001"
    }
#endif
    
    init(dirURL: URL, isSecurityScope: Bool, worldName: String) {
        self.dirURL = dirURL
        self.isSecurityScope = isSecurityScope
        self.worldName = worldName
    }
    
    init(dirURL: URL, isSecurityScope: Bool) {
        self.dirURL = dirURL
        self.isSecurityScope = isSecurityScope
        
        if isSecurityScope {
            guard dirURL.startAccessingSecurityScopedResource() else {
                self.worldName = "Error"
                return
            }
        }
        defer {
            if isSecurityScope {
                dirURL.stopAccessingSecurityScopedResource()
            }
        }
        
        let levelNameFileURL = dirURL.appendingPathComponent("levelname.txt", isDirectory: false)
        if let fileData = try? Data(contentsOf: levelNameFileURL), let name = String(data: fileData, encoding: .utf8) {
            self.worldName = name
        }
    }
    
    mutating func update() {
        guard !isSecurityScope else { return }
        let levelNameFileURL = dirURL.appendingPathComponent("levelname.txt", isDirectory: false)
        if let fileData = try? Data(contentsOf: levelNameFileURL), let name = String(data: fileData, encoding: .utf8) {
            self.worldName = name
        }
    }
    
    func move(to dstDir: URL) -> MCDir? {
        guard dstDir.startAccessingSecurityScopedResource() else { return nil }
        defer { dstDir.stopAccessingSecurityScopedResource() }
        
        let dstURL = dstDir.appendingPathComponent(self.dirURL.lastPathComponent, isDirectory: true)
        do {
            try FileManager.default.moveItem(at: self.dirURL, to: dstURL)
            return MCDir(dirURL: dstURL, isSecurityScope: true, worldName: worldName)
        } catch {
            print(error)
        }
        return nil
    }
    
    func copy(to dstDir: URL, newDirName: String? = nil) -> MCDir? {
        let oldName = dirURL.lastPathComponent
        let dstURL = dstDir.appendingPathComponent(newDirName ?? oldName, isDirectory: true)
        
        guard !self.isSecurityScope || dirURL.startAccessingSecurityScopedResource() else { return nil }
        defer {
            if self.isSecurityScope { dirURL.stopAccessingSecurityScopedResource() }
        }
        
        // FIXME: if directory already exists?
        
        do {
            try FileManager.default.copyItem(at: dirURL, to: dstURL)
            return MCDir(dirURL: dstURL, isSecurityScope: false, worldName: worldName)
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func parser() -> MCWorldKeyManager? {
        guard !isSecurityScope else { return nil }
        guard let db = LvDB(dbPath: dirURL.appendingPathComponent("db", isDirectory: true).path) else { return nil }
        guard let levelData = LevelData(srcURL: dirURL.appendingPathComponent("level.dat", isDirectory: false)) else { return nil }
        return MCWorldKeyManager(dirURL: dirURL, db: db, levelData: levelData)
    }
}

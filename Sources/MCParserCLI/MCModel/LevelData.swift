import Foundation
import SwiftNbt

class LevelData {
    var version: Int32
    var rootTag: NbtTag
    
    init?(srcURL: URL) {
        do {
            let nbtData = try! Data(contentsOf: srcURL)
            version = nbtData[0...3].int32
            // data length: nbtData[4...7].int32
            
            let stream = NbtBuffer(nbtData[8...])
            let reader = NbtReader(stream: stream, bigEndian: false)
            rootTag = try reader.readAsTag() as! NbtCompound
            if rootTag.tagType != .compound { return nil }
        } catch {
            print("Error: cannot init level data")
            return nil
        }
    }
    
    func save(dstURL: URL) {
        do {
            let ms = NbtBuffer()
            let writer = try NbtWriter(stream: ms, rootTagName: "", bigEndian: false)
            
            for tag in rootTag as! NbtCompound {
                try writer.writeTag(tag: tag)
            }
            
            try writer.endCompound()
            try writer.finish()
            
            let contentData = Data(ms.toArray())
            let data = version.data + Int32(contentData.count).data + contentData
            try data.write(to: dstURL)
        } catch {
            fatalError("Error: faild save")
        }
    }
    
    var worldName: String {
        get {
            return rootTag["LevelName"]?.name ?? ""
        }
        set {
            rootTag["LevelName"] = NbtString(name: "LevelName", newValue)
        }
    }
}

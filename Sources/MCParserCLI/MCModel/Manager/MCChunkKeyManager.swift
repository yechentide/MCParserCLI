import Foundation

@inlinable
func generateMapKey(_ xPos: Int32, _ zPos: Int32) -> String {
    return "\(xPos)_\(zPos)"
}

class MCChunkKeyManager {
    var overworld: [String:MCChunkKey] = [:]   // key:   xPos_zPos
    var theNether: [String:MCChunkKey] = [:]
    var theEnd: [String:MCChunkKey] = [:]
    
    func addChunk(dimension: MCDimension, xPos: Int32, zPos: Int32, type: MCChunkKeyType, subChunkIndex: Int8? = nil) {
        switch dimension {
        case .overworld:
            addChunk(to: &overworld, xPos: xPos, zPos: zPos, type: type, subChunkIndex: subChunkIndex)
        case .theNether:
            addChunk(to: &theNether, xPos: xPos, zPos: zPos, type: type, subChunkIndex: subChunkIndex)
        case .theEnd:
            addChunk(to: &theEnd, xPos: xPos, zPos: zPos, type: type, subChunkIndex: subChunkIndex)
        }
    }
    
    private func addChunk(to dic: inout [String:MCChunkKey], xPos: Int32, zPos: Int32, type: MCChunkKeyType, subChunkIndex: Int8? = nil) {
        let mapKey = generateMapKey(xPos, zPos)
        if let _ = dic[mapKey] {
            if type == .subChunkPrefix, let index = subChunkIndex {
                dic[mapKey]!.addSubChunk(index: index)
            } else {
                dic[mapKey]!.addChunkKeyType(type: type)
            }
        } else {
            var chunk = MCChunkKey(xIndex: xPos, zIndex: zPos)
            if type == .subChunkPrefix, let index = subChunkIndex {
                chunk.addSubChunk(index: index)
            } else {
                chunk.addChunkKeyType(type: type)
            }
            dic[mapKey] = chunk
        }
    }
    
    func deleteChunk(dimension: MCDimension, xPos: Int32, zPos: Int32) -> MCChunkKey? {
        switch dimension {
        case .overworld:
            return deleteChunk(from: &overworld, xPos: xPos, zPos: zPos)
        case .theNether:
            return deleteChunk(from: &theNether, xPos: xPos, zPos: zPos)
        case .theEnd:
            return deleteChunk(from: &theEnd, xPos: xPos, zPos: zPos)
        }
    }
    
    private func deleteChunk(from dic: inout [String:MCChunkKey], xPos: Int32, zPos: Int32) -> MCChunkKey? {
        let mapKey = generateMapKey(xPos, zPos)
        if let _ = dic[mapKey] {
            return dic.removeValue(forKey: mapKey)
        }
        return nil
    }
}

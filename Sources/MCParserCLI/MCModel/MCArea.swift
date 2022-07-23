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

extension MCArea {
    var startXPos: Int32 { Self.calcPos(index: xIndex, lowerBound: true) }
    var endXPos:   Int32 { Self.calcPos(index: xIndex, lowerBound: false) }
    var startZPos: Int32 { Self.calcPos(index: zIndex, lowerBound: true) }
    var endZPos:   Int32 { Self.calcPos(index: zIndex, lowerBound: false) }
    var xPosRange: ClosedRange<Int32> { startXPos...endXPos }
    var zPosRange: ClosedRange<Int32> { startZPos...endZPos }
    
    static func calcPos(index: Int32, lowerBound: Bool = true) -> Int32 {
        return lowerBound ? index*Self.length : (index+1)*Self.length-1
    }
    static func calcIndex(pos: Int32) -> Int32 {
        let result = floor(Double(pos) / Double(Self.length))
        return Int32(result)
    }
    static func caleIndex(xPos: Int32, zPos: Int32) -> (x: Int32, z: Int32) {
        let x = Self.calcIndex(pos: xPos)
        let z = Self.calcIndex(pos: zPos)
        return (x, z)
    }
    static func caleIndex(xPos: Int32, yPos: Int32, zPos: Int32) -> (x: Int32, y: Int32, z: Int32) {
        let x = Self.calcIndex(pos: xPos)
        let y = Self.calcIndex(pos: yPos)
        let z = Self.calcIndex(pos: zPos)
        return (x, y, z)
    }
}

//struct MCRigion: MCArea {
//    static var length: Int32 = 512
//    var xIndex: Int32
//    var zIndex: Int32
//}

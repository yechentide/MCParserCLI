//
//  File.swift
//  
//
//  Created by yechentide on 2022/06/10.
//

import Foundation

enum MCDimension: Int32 {
    case overworld = 0
    case theNether = 1
    case theEnd    = 2
    
    public var string: String {
        switch self {
        case .overworld:
            return "overworld"
        case .theNether:
            return "theNether"
        case .theEnd:
            return "theEnd"
        }
    }
}

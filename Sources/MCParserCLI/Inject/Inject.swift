//
//  File.swift
//  
//
//  Created by yechentide on 2022/06/10.
//

import ArgumentParser
import SwiftNbt
import Foundation
import LvDBWrapper

extension MCParserCLI {
    struct Inject: ParsableCommand {
        @Option(name: .customLong("db"), help: "The path of a db directory.")
        var dbDirPath: String
        
        @Option(name: .long, help: "")
        var key: String
        
        @Option(name: .customLong("data"), help: "")
        var dataPath: String
        
        func run() {
            guard let db = LvDB(dbPath: self.dbDirPath) else { return }
            guard key.count % 2 == 0 else {
                fatalError("Error: wrong key")
            }
            
            var keyData = Data()
            for i in 0...(key.count/2-1) {
                let start = key.index(key.startIndex, offsetBy: i*2)
                let end = key.index(key.startIndex, offsetBy: i*2+1)
                let byteStr = key[start...end]
                guard let byte = UInt8(byteStr, radix: 16) else { fatalError("Error: wrong key") }
                keyData.append(byte)
            }
            
            let valueData = try! Data(contentsOf: URL(fileURLWithPath: dataPath))
            let _ = db.setValue(keyData, valueData)
        }
    }
}

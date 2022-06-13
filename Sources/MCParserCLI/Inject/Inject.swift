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
import os

extension MCParserCLI {
    struct Inject: ParsableCommand {
        @Option(name: .customLong("db"), help: "The path of a db directory.")
        var dbDirPath: String
        
        @Option(name: .customLong("data"), help: "")
        var dataDirPath: String
        
        func run() {
            guard let db = LvDB(dbPath: dbDirPath) else { return }
            guard let dataFiles = try? FileManager.default.contentsOfDirectory(atPath: dataDirPath) else {
                print("Error: bad data dir path")
                os.exit(1)
            }
            
            for fileName in dataFiles {
                guard let key = fileName.hexData else {
                    continue
                }
                
                let url = URL(fileURLWithPath: dataDirPath).appendingPathComponent(fileName)
                guard let value = try? Data(contentsOf: url) else {
                    continue
                }
                
                let _ = db.setValue(key, value)
            }
        }
    }
}

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
        static var configuration = CommandConfiguration(
            commandName: "inject",
            abstract: "inject data into dleveldb",
            discussion: "Use this subcommand to inject data into dleveldb. The data source is file in specified directory, and the file name will be used as a key.",
            shouldDisplay: true
        )
        
        @Option(name: .customShort("d"), help: "Path of a db directory.")
        var dbDirPath: String
        
        @Option(name: .customShort("i"), help: "Path of a directory that contains data source files.")
        var dataDirPath: String
        
        func run() {
            guard let db = LvDB(dbPath: dbDirPath) else { return }
            
            var isDir: ObjCBool = false
            FileManager.default.fileExists(atPath: dataDirPath, isDirectory: &isDir)
            guard isDir.boolValue, let dataFiles = try? FileManager.default.contentsOfDirectory(atPath: dataDirPath) else {
                print("Error: wrong directory path, or no contens in the directory")
                os.exit(1)
            }
            
            for fileName in dataFiles {
                guard let key = fileName.hexData else {
                    print("Skip:", fileName, "File name should be a little endian hex string.")
                    continue
                }
                
                let url = URL(fileURLWithPath: dataDirPath).appendingPathComponent(fileName)
                guard let value = try? Data(contentsOf: url) else {
                    print("Skip:", fileName, "Canot read data from this file.")
                    continue
                }
                
                let _ = db.setValue(key, value)
            }
        }
    }
}

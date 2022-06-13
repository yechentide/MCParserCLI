//
//  File.swift
//  
//
//  Created by yechentide on 2022/06/04.
//

import ArgumentParser
import LvDBWrapper

extension MCParserCLI {
    struct Extract: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "extract",
            abstract: "extract data and save to files",
            discussion: "Use this subcommand to extract all data from leveldb.",
            shouldDisplay: true
        )
        
        @Option(name: .customShort("d"), help: "Path of a db directory.")
        var dbDirPath: String
        
        @Option(name: .customShort("o"), help: "Path where output directory is.")
        var outDirPath: String
        
        func run() {
            guard FileManager.default.fileExists(atPath: dbDirPath) else {
                fatalError("Error: db directory not found, wrong path >> \(dbDirPath) <<")
            }
            
            print("\n========== ========== ========== ========== ========== ==========")
            print("Extract data from \(dbDirPath)")
            
            guard let db = LvDB(dbPath: dbDirPath) else { return }
            guard let keyDataArray = db.getAllKeys() as? [Data] else { return }
            let pg = PathGenerator(rootPath: outDirPath)
            print("    to \(pg.rootDir)")
            
            for keyData in keyDataArray {
                let outputPath = pg.generatePath(key: keyData)
                let valueData = db.getValue(keyData)!
                
                let url = URL(fileURLWithPath: outputPath)
                try! valueData.write(to: url)
            }
            
            print("done!\n")
        }
    }
}

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
        //    @Option(name: .shortAndLong, help: "The number of times to repeat 'phrase'.")
        //    var count: Int?
        
        @Option(name: .short, help: "The path of a db directory")
        var dbDirPath: String
        
        @Option(name: .short, help: "The path where to output")
        var outDirPath: String
        
        func run() {
            guard FileManager.default.fileExists(atPath: self.dbDirPath) else {
                fatalError("Error: db directory not found at >> \(self.dbDirPath) <<")
            }
            
            print("\n========== ========== ========== ========== ========== ==========")
            print("Extract data from \(self.dbDirPath)")
            
            guard let db = LvDB(dbPath: self.dbDirPath) else { return }
            guard let keyDataArray = db.getAllKeys() as? [Data] else { return }
            let pg = PathGenerator(rootPath: self.outDirPath)
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

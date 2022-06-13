//
//  File.swift
//  
//
//  Created by yechentide on 2022/06/10.
//

import os
import Foundation
import ArgumentParser

extension MCParserCLI {
    struct Delete: ParsableCommand {
        @Option(name: .customLong("db"), help: "The path of a db directory.")
        var dbDirPath: String
        
        @Option(name: .customLong("dimension"), help: "")
        var dimension: Int32?
        @Option(name: .customLong("xstart"), help: "")
        var xStart: Int32?
        @Option(name: .customLong("xend"), help: "")
        var xEnd: Int32?
        @Option(name: .customLong("zstart"), help: "")
        var zStart: Int32?
        @Option(name: .customLong("zend"), help: "")
        var zEnd: Int32?
        
        func run() {
            guard let dimension = MCDimension(rawValue: dimension ?? -1) else {
                print("Error: wrong dimension"); os.exit(1)
            }
            guard let xStart = xStart, let xEnd = xEnd, let zStart = zStart, let zEnd = zEnd else {
                print("Error: wrong range"); os.exit(1)
            }
            guard let manager = MCChunkManager(dbDirPath: dbDirPath) else {
                print("Error: cannot open db"); os.exit(1)
            }
            
            print("\n========== ========== ========== ========== ========== ==========")
            print("Delete data from \(dbDirPath)")
            print(dimension, "xRange:", xStart...xEnd, "zRange:", zStart...zEnd)
            
            var x = xStart
            var z = zStart
            while z <= zEnd {
                manager.deleteChunk(dimension: dimension, xPos: x, zPos: z)
                
                x += 1
                if x > xEnd {
                    x = xStart
                    z += 1
                }
            }
            
            print("done!\n")
        }
    }
}

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
        static var configuration = CommandConfiguration(
            commandName: "delete",
            abstract: "delete chunks from leveldb",
            discussion: "Use this subcommand to delete chunks within the specified range.",
            shouldDisplay: true
        )
        
        @Option(name: .customLong("db"), help: "Path of a db directory.")
        var dbDirPath: String
        
        @Option(name: .customLong("dimension"), help: "World dimension. overworld = 0, theNether = 1, theEnd = 2")
        var dimension: Int32?
        @Option(name: .customLong("xstart"), help: "X postion of a chunk.")
        var xStart: Int32?
        @Option(name: .customLong("xend"), help: "X postion of a chunk.")
        var xEnd: Int32?
        @Option(name: .customLong("zstart"), help: "Z postion of a chunk.")
        var zStart: Int32?
        @Option(name: .customLong("zend"), help: "Z postion of a chunk.")
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

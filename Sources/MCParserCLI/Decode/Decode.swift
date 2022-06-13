//
//  File.swift
//  
//
//  Created by yechentide on 2022/06/10.
//

import ArgumentParser
import SwiftNbt
import Foundation

extension MCParserCLI {
    struct Decode: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "decode",
            abstract: "decode nbt data",
            discussion: "Use this subcommand to decode nbt data and save to a file.",
            shouldDisplay: true
        )
        
        @Argument(help: "Path of a nbt data file.")
        var source: String
        
        func run() {
            print("\n========== ========== ========== ========== ========== ==========")
            print("Decode nbt file \(source)")
            
            let srcURL = URL(fileURLWithPath: source)
            let fileName = srcURL.lastPathComponent + ".txt"
            let destURL = srcURL.deletingLastPathComponent().appendingPathComponent(fileName)
            
            let nbtData = try! Data(contentsOf: srcURL)
            let stream = NbtBuffer(nbtData)
            let reader = NbtReader(stream: stream, bigEndian: false)
            
            do {
                let rootTag = try reader.readAsTag() as! NbtCompound
                try rootTag.description.write(toFile: destURL.path, atomically: true, encoding: .utf8)
            } catch {
                print("Error: \(error)")
            }
            
            print("done!\n")
        }
    }
}

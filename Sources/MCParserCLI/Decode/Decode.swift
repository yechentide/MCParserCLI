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
        @Argument(help: "The path of a nbt data file.")
        var source: String
        
        func run() {
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
        }
    }
}

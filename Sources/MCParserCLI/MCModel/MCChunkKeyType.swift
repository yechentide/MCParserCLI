//
//  File.swift
//  
//
//  Created by yechentide on 2022/06/11.
//

import Foundation

///  Key types in leveldb.
///
///  [Chunk key format](https://minecraft.fandom.com/wiki/Bedrock_Edition_level_format)
///
///  [Non-Actor Data Chunk Key IDs](https://docs.microsoft.com/en-us/minecraft/creator/documents/actorstorage)
enum MCChunkKeyType: UInt8 {
    static let keyTypeStartWith: UInt8 = 0x2B
    
    case data3D                 = 0x2B
    case chunkVersion           = 0x2C      // This was moved to the front as needed for the extended heights feature. Old chunks will not have this data.
    case data2D                 = 0x2D
    case subChunkPrefix         = 0x2F
    case blockEntity            = 0x31
    case entity                 = 0x32
    case pendingTicks           = 0x33
    case biomeState             = 0x35
    case finalizedState         = 0x36
    case conversionData         = 0x37      // data that the converter provides, that are used at runtime for things like blending
    case borderBlocks           = 0x38
    case hardcodedSpawners      = 0x39
    case randomTicks            = 0x3A
    case checkSums              = 0x3B
    case generationSeed         = 0x3C
    case metaDataHash           = 0x3F
    case blendingData           = 0x40
    case actorDigestVersion     = 0x41
    
    // legacy key types
    case legacyData2D           = 0x2E
    case legacyTerrain          = 0x30
    case legacyBlockExtraData   = 0x34
    case generatedPreCavesAndCliffsBlending = 0x3D  // not used, DON'T REMOVE
    case blendingBiomeHeight    = 0x3E              // not used, DON'T REMOVE
    case legacyChunkVersion     = 0x76
}

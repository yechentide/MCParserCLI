import Foundation

enum MCWellKnownKey: String, CaseIterable {
    case autonomousEntities             = "AutonomousEntities"
    case biomeData                      = "BiomeData"
    case flatworldlayers                = "game_flatworldlayers"        // not sure
    case levelChunkMetaDataDictionary   = "LevelChunkMetaDataDictionary"
    case mobevents                      = "mobevents"
    case nether                         = "Nether"
    case overworld                      = "Overworld"
    case portals                        = "portals"
    case schedulerWT                    = "schedulerWT"
    case scoreboard                     = "scoreboard"
    case localPlayer                    = "~local_player"
    
    static func check(data: Data) -> Self? {
        guard let str = String(data: data, encoding: .utf8), let key = Self(rawValue: str) else { return nil }
        return key
    }
}
// map_
// player_
// VILLAGE_
// structuretemplate_
// actorprefix ...
// digp ...

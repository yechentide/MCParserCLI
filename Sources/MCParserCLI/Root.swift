import ArgumentParser

@main
struct MCParserCLI: ParsableCommand {
    // cf. https://blog.personal-factory.com/2020/06/06/how-to-start-swift-argument-parser/
    
    static var configuration = CommandConfiguration(
        commandName: "mcp",
        discussion: "A tool to handle data in Minecraft Bedrock's leveldb",
        shouldDisplay: true,
        subcommands: [
            Extract.self,
            Decode.self,
            Delete.self,
            Inject.self
        ]
    )
}

import ArgumentParser

@main
struct MCParserCLI: ParsableCommand {
    // cf. https://blog.personal-factory.com/2020/06/06/how-to-start-swift-argument-parser/
    
    static var configuration = CommandConfiguration(
        commandName: "mcp",
        abstract: "MCBEのためのコマンドラインツール",
        discussion: "MCBEのDB内のデータを扱うコマンドラインツール",
        //version: "0.0.1",
        shouldDisplay: true,
        subcommands: [
            Extract.self,
            Decode.self
        ]
    )
}

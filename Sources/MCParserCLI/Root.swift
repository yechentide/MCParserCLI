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
            Extract.self
        ]
    )
    
//    @Flag(help: "Include a counter with each repetition.")
//    var includeCounter = false

//    @Flag(name: .shortAndLong)
//    var version = false
    
//    @Option(name: .shortAndLong, help: "The number of times to repeat 'phrase'.")
//    var count: Int?
    
//    @Argument(help: "The phrase to repeat.")
//    var phrase: String
    
//    mutating func run() throws {
//        if version {
//            print(MCParserCLI.configuration.version)
//        }
//
//        MCParserCLICore.greet()
//        let repeatCount = count ?? 2
//
//        for i in 1...repeatCount {
//            if includeCounter {
//                print("\(i): \(phrase)")
//            } else {
//                print(phrase)
//            }
//        }
//    }
}

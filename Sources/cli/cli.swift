import ArgumentParser

@main
struct cli: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A command line tool to download files.",
        subcommands: [
            DownloadCommand.self
        ]
    )
}


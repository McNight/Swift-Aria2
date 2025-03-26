import ArgumentParser
import Foundation
import Noora
import SwiftAria2

struct DownloadCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "download",
        abstract: "The command to download resources using even BitTorrent"
    )

    @Argument(help: "The URLs locating the resource to download")
    var urls: [String]

    func run() async throws {
        try SwiftAria2.initialize()

        let session = try Session()
        let downloadHandle = try session.addURIs(urls)
        try await download(session: session, handle: downloadHandle)

        try SwiftAria2.deinitialize()
    }

    nonisolated func download(session: Session, handle: DownloadHandle) async throws {
        try await Noora().progressBarStep(
            message: "Downloading...",
            successMessage: "Downloaded!",
            errorMessage: "An error occured while downloading your resource."
        ) { updateProgress in
            let clock = ContinuousClock()
            var tick = clock.now

            while true {
                guard session.runOnce() == 1 else {
                    break
                }

                let now = clock.now
                if (now - tick) > .milliseconds(250) {
                    for handle in session.getActiveDownloadHandles {
                        let totalLength = Double(handle.totalLength)
                        let completedLength = Double(handle.completedLength)

                        let progress = totalLength > 0 ? completedLength / totalLength : 0

                        updateProgress(progress)
                    }
                    tick = now
                }
            }
        }
    }
}

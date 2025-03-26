import Testing

import Foundation
@testable import URLSessionBindings

@Test
func sessionTaskBindings() async throws {
    #expect(!URLSession.ariaEnabled)

    URLSession.ariaEnabled = true

    let url = URL(string: "https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/aarch64/alpine-standard-3.21.3-aarch64.iso")!

    let task = URLSession.shared.downloadTask(with: url) { fileURL, response, error in
        #expect(fileURL != nil)
        #expect(error == nil)
    }

    #expect(task.state == .suspended)

    task.resume()

    // need to check libaria2 on why state/status is not updated
    // #expect(task.state == .completed)
}

@Test
func multiURIsSessionTaskBindings() async throws {
    #expect(!URLSession.ariaEnabled)

    URLSession.ariaEnabled = true

    let url1 = URL(string: "https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/aarch64/alpine-standard-3.21.3-aarch64.iso")!
    let url2 = URL(string: "https://ftp.halifax.rwth-aachen.de/alpine/v3.21/releases/aarch64/alpine-standard-3.21.3-aarch64.iso")!
    let url3 = URL(string: "https://uk.alpinelinux.org/alpine/v3.21/releases/aarch64/alpine-standard-3.21.3-aarch64.iso")!

    let task = URLSession.shared.downloadTask(with: url1, url2, url3) { fileURL, response, error in
        #expect(fileURL != nil)
        #expect(error == nil)
    }

    #expect(task.state == .suspended)

    task.resume()

    // need to check libaria2 on why state/status is not updated
    // #expect(task.state == .completed)
}

@Test
func magnetLinkURISessionTaskBinding() async throws {
    #expect(!URLSession.ariaEnabled)

    URLSession.ariaEnabled = true

    let url = URL(string: "magnet:?xt=urn:btih:WSBAPEWJHOT7LWWLXBHAOMOLVZRIGPLG")!

    let task = URLSession.shared.downloadTask(with: url) { fileURL, response, error in
        #expect(fileURL != nil)
        #expect(error == nil)
    }

    #expect(task.state == .suspended)

    task.resume()

    // Debian iso downloaded! :)
}

import Foundation
import SwiftAria2
import Synchronization

extension URLSession {
    public static var ariaEnabled: Bool {
        get {
            return _ariaEnabled.withLock { $0 }
        }
        set {
            try! _ariaEnabled.withLock { wrappedValue in
                do {
                    try SwiftAria2.initialize()
                    Self.ariaSession = try! Session()
                } catch SwiftAria2.Error.alreadyInitialized {
                    // no-op
                } catch {
                    throw error
                }

                wrappedValue = newValue
            }
        }
    }

    private static let _ariaEnabled = Mutex<Bool>.init(false)
}

nonisolated(unsafe) private var ariaSessionKey: UInt8 = 1 << 1

extension URLSession {
    static var ariaSession: Session {
        get {
            objc_getAssociatedObject(self, &ariaSessionKey) as! Session
        }
        set {
            objc_setAssociatedObject(
                self,
                &ariaSessionKey,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}

extension URLSession {
    func downloadTask(with urls: URL...) -> URLSessionDownloadTask {
        guard !urls.isEmpty else {
            fatalError()
        }
        // kinda ugly...
        Self.ariaEnabled = false
        let ogTask = downloadTask(with: urls[0])
        Self.ariaEnabled = true
        let ariaSession = URLSession.ariaSession
        let handle: DownloadHandle
        if urls.count > 1 {
            handle = try! ariaSession.addURIs(urls[1...].map(\.absoluteString))
        } else {
            handle = try! ariaSession.addURI(urls[0].absoluteString)
        }
        ogTask.ariaDownloadHandle = handle
        return ogTask
    }

    func downloadTask(
        with urls: URL...,
        completionHandler: @escaping @Sendable (URL?, URLResponse?, (any Error)?) -> Void
    ) -> URLSessionDownloadTask {
        guard !urls.isEmpty else {
            fatalError()
        }
        // kinda ugly...
        Self.ariaEnabled = false
        let ogTask = downloadTask(with: urls[0])
        Self.ariaEnabled = true
        let ariaSession = URLSession.ariaSession
        let handle: DownloadHandle
        if urls.count > 1 {
            handle = try! ariaSession.addURIs(urls.map(\.absoluteString))
        } else {
            handle = try! ariaSession.addURI(urls[0].absoluteString)
        }
        handle.completionHandler = completionHandler
        ogTask.ariaDownloadHandle = handle
        return ogTask
    }
}

extension URLSession {
    private static let swizzleDownloadTaskImplementation: Void = swizzleHandler(
        original: #selector((URLSession.downloadTask(with:) as (URLSession) -> ((URL) -> URLSessionDownloadTask))),
        replacement: #selector(URLSession.aria_downloadTask(with:)),
        for: URLSession.self
    )()

    private static let swizzleDownloadTaskWithCompletionImplementation: Void = swizzleHandler(
        original: #selector((URLSession.downloadTask(with:completionHandler:) as (URLSession) -> ((URL, @Sendable @escaping (URL?, URLResponse?, (any Error)?) -> Void) -> URLSessionDownloadTask))),
        replacement: #selector(URLSession.aria_downloadTask(with:completionHandler:)),
        for: URLSession.self
    )()

    @objc
    package static func performSwizzling() {
        _ = self.swizzleDownloadTaskImplementation
        _ = self.swizzleDownloadTaskWithCompletionImplementation
    }
}

extension URLSession {
    @objc
    func aria_downloadTask(with url: URL) -> URLSessionDownloadTask {
        let ogTask = aria_downloadTask(with: url)
        guard Self.ariaEnabled else {
            return ogTask
        }
        let ariaSession = URLSession.ariaSession
        let rv = try! ariaSession.addURIs([url.absoluteString])
        ogTask.ariaDownloadHandle = rv
        return ogTask
    }

    @objc
    func aria_downloadTask(
        with url: URL,
        completionHandler: @escaping @Sendable (URL?, URLResponse?, (any Error)?) -> Void
    ) -> URLSessionDownloadTask {
        let ogTask = aria_downloadTask(with: url, completionHandler: completionHandler)
        guard Self.ariaEnabled else {
            return ogTask
        }
        let ariaSession = URLSession.ariaSession
        let rv = try! ariaSession.addURI(url.absoluteString)
        rv.completionHandler = completionHandler
        ogTask.ariaDownloadHandle = rv
        return ogTask
    }
}

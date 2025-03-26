import CxxAria2
import CxxStdlib
import Foundation

private func rawDownloadEventCallback(
    _ session: OpaquePointer?,
    _ event: aria2.DownloadEvent,
    _ gid: aria2.A2Gid,
    _ userData: UnsafeMutableRawPointer?
) -> Int32 {
    guard let session, let swiftSession = Session.sessions[session] else {
        fatalError("No Swift Session found associated to this pointer")
    }
    return swiftSession.downloadEventCallback(gid: gid, event: event)
}

public enum SessionError: Error {
    case initializationFailure
    case unableToAddURI
    case ariaDownloadError(Int32)
}

public final class Session {
    nonisolated(unsafe) static var sessions: [OpaquePointer: Session] = [:]

    let sessionPtr: OpaquePointer
    let queue: DispatchQueue

    private var activeDownloadHandles: [aria2.A2Gid: DownloadHandle] = [:]

    public init(queue: DispatchQueue = DispatchQueue(label: "com.mcnight.aria2.urlsession")) throws(SessionError) {
        let keyVals = aria2.KeyVals()
        var config = aria2.SessionConfig()
        config.downloadEventCallback = rawDownloadEventCallback
        guard let ariaSessionPtr = aria2.sessionNew(keyVals, config) else {
            throw .initializationFailure
        }
        self.sessionPtr = ariaSessionPtr
        self.queue = queue
        Self.sessions[ariaSessionPtr] = self
    }

    deinit {
        _ = queue.sync {
            aria2.sessionFinal(sessionPtr)
        }
    }
}

public extension Session {
    var globalStats: aria2.GlobalStat {
        queue.sync { aria2.getGlobalStat(sessionPtr) }
    }

    var getActiveDownloadIDs: [aria2.A2Gid] {
        Array(aria2.getActiveDownload(sessionPtr))
    }

    var getActiveDownloadHandles: [DownloadHandle] {
        aria2.getActiveDownload(sessionPtr).map { DownloadHandle(session: self, gid: $0) }
    }
}

public extension Session {
    @discardableResult
    func addURI(_ uri: String) throws -> DownloadHandle {
        try queue.sync {
            var vector = UrisVector()
            vector.reserve(1)
            vector.push_back(std.string(uri))
            var gid: aria2.A2Gid = 0
            let options = aria2.KeyVals()
            guard aria2.addUri(sessionPtr, &gid, vector, options) == 0 else {
                throw SessionError.unableToAddURI
            }
            let dh = DownloadHandle(session: self, gid: gid)
            activeDownloadHandles[gid] = dh
            return dh
        }
    }

    @discardableResult
    func addURIs(_ uris: some Collection<String>) throws -> DownloadHandle {
        try queue.sync {
            var vector = UrisVector()
            vector.reserve(uris.count)
            for uri in uris {
                vector.push_back(std.string(uri))
            }
            var gid: aria2.A2Gid = 0
            let options = aria2.KeyVals()
            guard aria2.addUri(sessionPtr, &gid, vector, options) == 0 else {
                throw SessionError.unableToAddURI
            }
            let dh = DownloadHandle(session: self, gid: gid)
            activeDownloadHandles[gid] = dh
            return dh
        }
    }

    func run() -> Int32 {
        queue.sync { aria2.run(sessionPtr, aria2.RUN_DEFAULT) }
    }

    func runOnce() -> Int32 {
        queue.sync { aria2.run(sessionPtr, aria2.RUN_ONCE) }
    }

    func runAsync() async -> Int32 {
        await withCheckedContinuation { continuation in
            continuation.resume(returning: run())
        }
    }

    func runOnceAsync() async -> Int32 {
        await withCheckedContinuation { continuation in
            continuation.resume(returning: runOnce())
        }
    }

    func removeDownload(_ handle: DownloadHandle, force: Bool = false) -> Int32 {
        queue.sync { aria2.removeDownload(sessionPtr, handle.gid, force) }
    }

    func pauseDownload(_ handle: DownloadHandle, force: Bool = false) -> Int32 {
        queue.sync { aria2.pauseDownload(sessionPtr, handle.gid, force) }
    }

    func unpauseDownload(_ handle: DownloadHandle) -> Int32 {
        queue.sync { aria2.unpauseDownload(sessionPtr, handle.gid) }
    }
}

extension Session {
    func downloadEventCallback(gid: aria2.A2Gid, event: aria2.DownloadEvent) -> Int32 {
        guard let downloadHandle = activeDownloadHandles[gid] else {
            return -1
        }
        switch event {
        case aria2.EVENT_ON_DOWNLOAD_COMPLETE, aria2.EVENT_ON_BT_DOWNLOAD_COMPLETE:
            _ = removeDownload(downloadHandle)
            let file = downloadHandle.filesPaths[0]
            downloadHandle.completionHandler?(URL(string: file), nil, nil)
        case aria2.EVENT_ON_DOWNLOAD_ERROR:
            _ = removeDownload(downloadHandle)
            downloadHandle.completionHandler?(nil, nil, SessionError.ariaDownloadError(downloadHandle.errorCode))
        default:
            break
        }
        activeDownloadHandles.removeValue(forKey: gid)
        return 0
    }
}

import CxxAria2
import Foundation

public final class DownloadHandle {
    package typealias CompletionHandler = (URL?, URLResponse?, (any Error)?) -> Void

    package var completionHandler: CompletionHandler?

    let gid: aria2.A2Gid

    private let handle: CxxAria2.DownloadHandle

    init(session: Session, gid: aria2.A2Gid) {
        self.gid = gid
        let ariaHandle = aria2.getDownloadHandle(session.sessionPtr, gid)
        self.handle = CxxAria2.DownloadHandle(ariaHandle)
    }
}

public extension DownloadHandle {
    var status: aria2.DownloadStatus {
        handle.getStatus()
    }

    var dir: String {
        String(handle.getDir())
    }

    var errorCode: Int32 {
        handle.getErrorCode()
    }

    var files: [aria2.FileData] {
        Array(handle.getFiles())
    }

    var filesPaths: [String] {
        handle.getFiles().map { String($0.path) }
    }

    var downloadSpeed: Int32 {
        handle.getDownloadSpeed()
    }

    var uploadSpeed: Int32 {
        handle.getUploadSpeed()
    }

    var totalLength: Int64 {
        handle.getTotalLength()
    }

    var completedLength: Int64 {
        handle.getCompletedLength()
    }
}

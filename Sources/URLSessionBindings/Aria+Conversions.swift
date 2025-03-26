import CxxAria2
import Foundation

extension aria2.DownloadStatus {
    var toTaskState: URLSessionTask.State {
        switch self {
        case aria2.DOWNLOAD_ACTIVE:
            return .running
        case aria2.DOWNLOAD_PAUSED, aria2.DOWNLOAD_WAITING:
            return .suspended
        case aria2.DOWNLOAD_REMOVED, aria2.DOWNLOAD_ERROR:
            return .canceling
        case aria2.DOWNLOAD_COMPLETE:
            return .completed
        default:
            return .completed
        }
    }
}

import Foundation
import SwiftAria2

nonisolated(unsafe) private var ariaDownloadHandleKey: UInt8 = 1 << 1

extension URLSessionTask {
    var ariaDownloadHandle: DownloadHandle? {
        get {
            return objc_getAssociatedObject(self, &ariaDownloadHandleKey) as? DownloadHandle
        }
        set {
            objc_setAssociatedObject(
                self,
                &ariaDownloadHandleKey,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}

extension URLSessionTask {
    private static let swizzleResumeImplementation: Void = swizzleHandler(
        original: #selector(URLSessionTask.resume),
        replacement: #selector(URLSessionTask.aria_resume),
        for: URLSessionTask.self
    )()

    private static let swizzleCancelImplementation: Void = swizzleHandler(
        original: #selector(URLSessionTask.cancel),
        replacement: #selector(URLSessionTask.aria_cancel),
        for: URLSessionTask.self
    )()

    private static let swizzleSuspendImplementation: Void = swizzleHandler(
        original: #selector(URLSessionTask.suspend),
        replacement: #selector(URLSessionTask.aria_suspend),
        for: URLSessionTask.self
    )()

    private static let swizzleStateImplementation: Void = swizzleHandler(
        original: #selector(getter: URLSessionTask.state),
        replacement: #selector(getter: URLSessionTask.aria_state),
        for: URLSessionTask.self
    )()

    @objc
    package static func performSwizzling() {
        _ = self.swizzleResumeImplementation
        _ = self.swizzleCancelImplementation
        _ = self.swizzleSuspendImplementation
        _ = self.swizzleStateImplementation
    }
}

extension URLSessionTask {
    @objc
    var aria_state: URLSessionTask.State {
        guard URLSession.ariaEnabled, let ariaDownloadHandle else {
            return self.aria_state
        }
        return ariaDownloadHandle.status.toTaskState
    }

    @objc
    func aria_resume() {
        guard URLSession.ariaEnabled, ariaDownloadHandle != nil  else {
            aria_resume()
            return
        }
        _ = URLSession.ariaSession.run()
    }

    @objc
    func aria_cancel() {
        guard URLSession.ariaEnabled, let ariaDownloadHandle else {
            aria_cancel()
            return
        }
        _ = URLSession.ariaSession.removeDownload(ariaDownloadHandle, force: true)
    }

    @objc
    func aria_suspend() {
        guard URLSession.ariaEnabled, let ariaDownloadHandle else {
            aria_suspend()
            return
        }
        _ = URLSession.ariaSession.pauseDownload(ariaDownloadHandle, force: true)
    }
}

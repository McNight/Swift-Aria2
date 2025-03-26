import CxxAria2
import Foundation

public enum SwiftAria2 {
    public enum Error: Swift.Error {
        case alreadyInitialized
        case neverInitialized
        case aria2Error(Int32)
    }

    nonisolated(unsafe) private static var hasInitialized = false

    public static func initialize() throws(Error) {
        guard !hasInitialized else { throw .alreadyInitialized }
        let rv = aria2.libraryInit()
        if rv != 0 {
            throw .aria2Error(rv)
        }
        hasInitialized = true
    }

    public static func deinitialize() throws(Error) {
        guard hasInitialized else { throw .neverInitialized }
        let rv = aria2.libraryDeinit()
        if rv != 0 {
            throw .aria2Error(rv)
        }
    }
}

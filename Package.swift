// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-aria2",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "SwiftAria2",
            targets: ["SwiftAria2"]
        ),
        .library(
            name: "URLSessionBindings",
            targets: ["URLSessionBindings"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
        .package(url: "https://github.com/tuist/Noora", .upToNextMajor(from: "0.15.0")),
    ],
    targets: [
        .target(
            name: "SwiftAria2",
            dependencies: [
                .target(name: "CxxAria2")
            ],
            swiftSettings: [.interoperabilityMode(.Cxx)],
            linkerSettings: [
                .unsafeFlags([
                    "-L", "/opt/homebrew/lib"
                ]),
                .linkedLibrary("cares", .when(platforms: [.macOS])),
                .unsafeFlags([
                    "-L", "/opt/homebrew/opt/libssh2/"
                ]),
                .linkedLibrary("caresios", .when(platforms: [.iOS])),
                .linkedLibrary("zip", .when(platforms: [.macOS])),
                .linkedLibrary("zipios", .when(platforms: [.iOS])),
                .unsafeFlags([
                    "-L", "/opt/homebrew/opt/libssh2/"
                ]),
                .linkedLibrary("ssh2", .when(platforms: [.macOS])),
                .linkedLibrary("ssh2ios", .when(platforms: [.iOS])),
                .unsafeFlags([
                    "-L", "/opt/homebrew/opt/zlib/lib"
                ]),
                .linkedLibrary("z", .when(platforms: [.macOS])),
                .linkedLibrary("zios", .when(platforms: [.iOS])),
                .unsafeFlags([
                    "-L", "/opt/homebrew/opt/expat/lib"
                ]),
                .linkedLibrary("expat", .when(platforms: [.macOS])),
                .linkedLibrary("expatios", .when(platforms: [.iOS])),
            ]
        ),
        .target(
            name: "URLSessionBindingsLoader",
            dependencies: [
                .target(name: "SwiftAria2")
            ],
            publicHeadersPath: "."
        ),
        .target(
            name: "URLSessionBindings",
            dependencies: [
                .target(name: "SwiftAria2"),
                .target(name: "URLSessionBindingsLoader")
            ],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
        .target(
            name: "CxxAria2",
            dependencies: [
                .target(name: "aria2")
            ],
            publicHeadersPath: ".",
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
        .binaryTarget(
            name: "aria2",
            path: "Frameworks/aria2.xcframework"
        ),
        .executableTarget(
            name: "cli",
            dependencies: [
                .target(name: "SwiftAria2"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Noora", package: "Noora")
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),
            ]
        ),
        .testTarget(
            name: "SwiftAria2Tests",
            dependencies: ["URLSessionBindings"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ]
)

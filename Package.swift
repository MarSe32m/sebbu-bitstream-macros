// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "sebbu-bit-stream-macros",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SebbuBitStreamMacros",
            targets: ["SebbuBitStreamMacros"]
        ),
        .executable(
            name: "SebbuBitStreamMacroClient",
            targets: ["SebbuBitStreamMacroClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.2"),
        .package(url: "https://github.com/MarSe32m/sebbu-bitstream.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "SebbuBitStreamMacrosLib",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "SebbuBitStreamMacros", dependencies: ["SebbuBitStreamMacrosLib",
                                                             .product(name: "SebbuBitStream", package: "sebbu-bitstream")]),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "SebbuBitStreamMacroClient", dependencies: ["SebbuBitStreamMacros",
                                                                       .product(name: "SebbuBitStream", package: "sebbu-bitstream")]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "SebbuBitStreamMacrosTests",
            dependencies: [
                "SebbuBitStreamMacrosLib",
                "SebbuBitStreamMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "SebbuBitStream", package: "sebbu-bitstream")
            ]
        ),
    ]
)

// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SomariKit",
    platforms: [.macOS(.v26), .iOS(.v26)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SomariKit",
            targets: [
                "UIComponents",
                "SomariKit",
                "FeedCore",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0-latest"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.6.1"),
        .package(url: "https://github.com/nmdias/FeedKit.git", from: "10.1.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "SomariKitMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(
            name: "SomariKit",
            dependencies: [
                "SomariKitMacros",
                "Kingfisher",
            ]
        ),
        .target(
            name: "UIComponents",
            dependencies: [
                "SomariKit",
            ]
        ),
        .target(
            name: "FeedCore",
            dependencies: [
                "SomariKit",
                "FeedKit",
            ]
        ),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "SomariKitTests",
            dependencies: [
                "SomariKitMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)

// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "MacrosForStroblMocks",
    platforms: [.macOS(.v12), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MacrosForStroblMocks",
            targets: ["MacrosForStroblMocks"]
        ),
        .executable(
            name: "MacrosForStroblMocksClient",
            targets: ["MacrosForStroblMocksClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", .upToNextMajor(from: "0.55.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "MacrosForStroblMocksMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(
            name: "MacrosForStroblMocks",
            dependencies: ["MacrosForStroblMocksMacros"],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(
            name: "MacrosForStroblMocksClient",
            dependencies: ["MacrosForStroblMocks"],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "MacrosForStroblMocksTests",
            dependencies: [
                "MacrosForStroblMocksMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),

        // A test target used to verify the errors produced by the macros
        .testTarget(
            name: "MacrosForStroblMocksClientTests",
            dependencies: [
                "MacrosForStroblMocksClient",
                "MacrosForStroblMocksMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)

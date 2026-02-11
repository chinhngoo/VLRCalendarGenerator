// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VLRCalendarGenerator",
    platforms: [
        .macOS(.v26)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.11.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "vlr-calendar-generator",
            dependencies: [
                .product(name: "SwiftSoup", package: "SwiftSoup"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
    ]
)

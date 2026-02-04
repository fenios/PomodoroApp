// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PomodoroSettings",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PomodoroSettings",
            targets: ["PomodoroSettings"]
        ),
    ],
    dependencies: [
        .package(path: "../PomodoroTimerCore"), // Path relative to Modules/PomodoroSettings
        .package(url: "https://github.com/apple/swift-testing.git", from: "0.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PomodoroSettings",
            dependencies: [
                .product(name: "PomodoroTimerCore", package: "PomodoroTimerCore"),
            ]
        ),
        .testTarget(
            name: "PomodoroSettingsTests",
            dependencies: [
                "PomodoroSettings",
                .product(name: "Testing", package: "swift-testing"),
            ]
        ),
    ]
)

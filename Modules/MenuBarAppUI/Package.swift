// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MenuBarAppUI",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MenuBarAppUI",
            targets: ["MenuBarAppUI"]
        ),
    ],
    dependencies: [
        .package(path: "../PomodoroTimerCore"), // Path relative to Modules/MenuBarAppUI
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MenuBarAppUI",
            dependencies: [
                .product(name: "PomodoroTimerCore", package: "PomodoroTimerCore"),
            ]
        ),
        .testTarget(
            name: "MenuBarAppUITests",
            dependencies: [
                "MenuBarAppUI",
            ]
        ),
    ]
)

// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Schedule",
     platforms: [.iOS(.v10), .macOS(.v10_15), .watchOS(.v3), .tvOS(.v10)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Schedule",
            targets: ["Schedule"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/vale-cocoa/VDLGCDHelpers.git", from: "1.0.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Schedule",
            dependencies: ["VDLGCDHelpers"]),
        .testTarget(
            name: "ScheduleTests",
            dependencies: ["Schedule"]),
    ]
)

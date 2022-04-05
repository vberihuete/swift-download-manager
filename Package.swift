// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-download-manager",
//    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftDownloadManager",
            targets: ["swift-download-manager"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "Nimble", url: "https://github.com/Quick/Nimble.git", from: Version(9, 2, 1)),
        .package(name: "Quick", url: "https://github.com/Quick/Quick.git", from: Version(4, 0, 0))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "swift-download-manager",
            dependencies: []),
        .testTarget(
            name: "swift-download-managerTests",
            dependencies: ["swift-download-manager", "Quick", "Nimble"]),
    ]
)

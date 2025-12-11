// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JsonWrapper",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "JsonWrapper",
            targets: ["JsonWrapper"]),
    ],
    dependencies: [],
    targets: [
        // C++ Target: nlohamnn/json + C-API bridge
        .target(
            name: "CxxJsonParser",
            dependencies: [],
            path: "Sources/CxxJsonParser",
            sources: ["JsonWrapper.cpp"],
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("include")
            ],
            linkerSettings: [
                .linkedLibrary("c++")
            ]
        ),
        // Swift Target: Public API Wrapper
        .target(
            name: "JsonWrapper",
            dependencies: ["CxxJsonParser"]
        ),
        
        // Tests
        .testTarget(
            name: "JsonWrapperTests",
            dependencies: ["JsonWrapper"]
        ),
    ],
    
    cxxLanguageStandard: .cxx17
)

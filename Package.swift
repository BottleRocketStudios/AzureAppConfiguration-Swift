// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "AzureAppConfiguration",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "AzureAppConfiguration",
            targets: ["AzureAppConfiguration"]),
    ],
    targets: [
        .target(
            name: "AzureAppConfiguration",
            dependencies: []),
        .testTarget(
            name: "AzureAppConfigurationTests",
            dependencies: ["AzureAppConfiguration"]),
    ]
)

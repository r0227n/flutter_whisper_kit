// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FlutterWhisperkitApple",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "FlutterWhisperkitApple",
            targets: ["FlutterWhisperkitApple"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/argmaxinc/WhisperKit.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "FlutterWhisperkitApple",
            dependencies: ["WhisperKit"],
            path: "Classes"
        )
    ]
) 
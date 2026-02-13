// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "WhatsNewKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "WhatsNewKit",
            targets: [
                "WhatsNewKit"
            ]
        )
    ],
    targets: [
        .target(
            name: "WhatsNewKit",
            path: "Sources",
            resources: [
                .process("Resources/PrivacyInfo.xcprivacy")
            ]
        ),
        .testTarget(
            name: "WhatsNewKitTests",
            dependencies: [
                "WhatsNewKit"
            ],
            path: "Tests"
        )
    ]
)

// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FocusSessionLogger",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "FocusSessionLogger",
            path: "Sources/FocusSessionLogger",
            exclude: ["Info.plist"],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-sectcreate",
                              "-Xlinker", "__TEXT",
                              "-Xlinker", "__info_plist",
                              "-Xlinker", "Sources/FocusSessionLogger/Info.plist"])
            ]
        )
    ]
)

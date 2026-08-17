// swift-tools-version: 6.3.3

import PackageDescription

let package = Package(
    name: "swift-scheduler",
    platforms: [
        .macOS("27")
    ],
    products: [
        .library(name: "Scheduler", targets: ["Scheduler"])
    ],
    targets: [
        // MARK: - Scheduler (engine-free background-jobs interface)

        .target(
            name: "Scheduler",
            path: "Sources/Scheduler"
        ),

        // MARK: - Tests

        .testTarget(
            name: "Scheduler Tests",
            dependencies: ["Scheduler"],
            path: "Tests/Scheduler Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

// Build settings, mirroring the swift-server / swift-sql membrane trio. `Scheduler` carries no
// engine dependency, but the same InternalImportsByDefault / MemberImportVisibility / ExistentialAny
// baseline keeps this L3 interface aligned with the packages whose Live conformances consume it.
for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let membrane: [SwiftSetting] = [
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("ExistentialAny"),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + membrane
}

#if canImport(PackageDescription)
// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "ExpenseTracker",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "ExpenseTracker",
            targets: ["ExpenseTracker"]
        )
    ],
    dependencies: [
        // Add any external dependencies here if needed
    ],
    targets: [
        .target(
            name: "ExpenseTracker",
            dependencies: [],
            path: "ExpenseTracker"
        )
    ]
)

#endif


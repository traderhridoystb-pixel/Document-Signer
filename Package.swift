// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Signer",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Signer",
            targets: ["Signer"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/RevenueCat/purchases-ios-spm.git",
            from: "5.0.0"
        ),
    ],
    targets: [
        .target(
            name: "Signer",
            dependencies: [
                .product(name: "RevenueCat", package: "purchases-ios-spm"),
                .product(name: "RevenueCatUI", package: "purchases-ios-spm"),
            ],
            path: "Signer"
        ),
        .testTarget(
            name: "SignerTests",
            dependencies: ["Signer"],
            path: "SignerTests"
        ),
    ]
)

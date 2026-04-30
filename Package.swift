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
    targets: [
        .target(
            name: "Signer",
            path: "Signer"
        ),
        .testTarget(
            name: "SignerTests",
            dependencies: ["Signer"],
            path: "SignerTests"
        ),
    ]
)

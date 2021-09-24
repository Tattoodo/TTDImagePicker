// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TTDImagePicker",
    defaultLocalization: "en",
    platforms: [.iOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TTDImagePicker",
            targets: ["TTDImagePicker"]),
    ],
    targets: [
        .binaryTarget(
            name: "TTDImagePicker",
            path: "/build/TTDImagePicker.xcframework"
        )
    ]
)
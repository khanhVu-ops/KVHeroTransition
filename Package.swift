//
//  Package.swift
//  KVHeroTransition
//
//  Created by Khanh Vu on 4/6/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "KVHeroTransition",
    platforms: [
        .iOS(.v13) // 🟢 KHỚP với podspec
    ],
    products: [
        .library(
            name: "KVHeroTransition",
            targets: ["KVHeroTransition"]
        ),
    ],
    targets: [
        .target(
            name: "KVHeroTransition",
            path: "Sources/KVHeroTransition",
            publicHeadersPath: "" // Nếu là Swift thì không cần header
        )
    ]
)

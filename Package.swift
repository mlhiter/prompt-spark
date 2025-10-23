// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PromptSpark",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "PromptSpark", targets: ["PromptSpark"])
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "PromptSpark",
            dependencies: ["KeyboardShortcuts"],
            path: ".",
            exclude: [
                "README.md",
                "DEVELOPMENT.md",
                "CLAUDE.md",
                "tech-architecture.md",
                "white-paper.md",
                ".gitignore",
                ".build",
                ".claude"
            ],
            sources: [
                "App",
                "Core",
                "Models",
                "Views",
                "Services",
                "Utils"
            ],
            resources: [.process("Resources")]
        )
    ]
)

import ProjectDescription

// MARK: - Constants

public enum ProjectConfig {
    public static let organizationName = "Newdok"
    public static let bundlePrefix = "com.newdok"
    public static let deploymentTarget: DeploymentTargets = .iOS("18.0")
    public static let destinations: Destinations = .iOS

    public static let baseSettings: SettingsDictionary = [
        "SKIP_INSTALL": "YES",
        "SWIFT_STRICT_CONCURRENCY": "complete"
    ]

    public static let featureSettings: SettingsDictionary = [
        "SWIFT_INSTALL_OBJC_HEADER": "NO",
        "SKIP_INSTALL": "YES",
        "SWIFT_STRICT_CONCURRENCY": "complete"
    ]
}

// MARK: - Dependency Shortcuts

public extension TargetDependency {
    static let shared: TargetDependency = .project(target: "Shared", path: .relativeToRoot("Modules/Shared"))
    static let core: TargetDependency = .project(target: "Core", path: .relativeToRoot("Modules/Core"))
    static let designSystem: TargetDependency = .project(target: "DesignSystem", path: .relativeToRoot("Modules/DesignSystem"))

    static func feature(_ name: String) -> TargetDependency {
        .project(target: name, path: .relativeToRoot("Modules/Features/\(name)"))
    }

    static func featureInterface(_ name: String) -> TargetDependency {
        .project(target: "\(name)Interface", path: .relativeToRoot("Modules/Features/\(name)"))
    }

    static func featureDomain(_ name: String) -> TargetDependency {
        .project(target: "\(name)Domain", path: .relativeToRoot("Modules/Features/\(name)"))
    }

    static func featureData(_ name: String) -> TargetDependency {
        .project(target: "\(name)Data", path: .relativeToRoot("Modules/Features/\(name)"))
    }

    static func featureTesting(_ name: String) -> TargetDependency {
        .project(target: "\(name)Testing", path: .relativeToRoot("Modules/Features/\(name)"))
    }
}

// MARK: - Feature Project (TMA)

public extension Project {
    /// TMA 구조의 Feature 모듈 생성
    ///
    /// 생성되는 타겟:
    /// - `{name}Interface` : 프로토콜/인터페이스 (staticFramework)
    /// - `{name}Domain`    : UseCase, Entity (staticFramework) — hasDomain=true
    /// - `{name}Data`      : Repository 구현체 (staticFramework) — hasData=true
    /// - `{name}`          : View, ViewModel (staticFramework)
    /// - `{name}Testing`   : Mock/Stub (staticFramework) — hasTesting=true
    /// - `{name}Tests`     : 단위 테스트 (unitTests) — hasTests=true
    static func feature(
        name: String,
        interfaceDependencies: [TargetDependency] = [],
        domainDependencies: [TargetDependency] = [],
        dataDependencies: [TargetDependency] = [],
        featureDependencies: [TargetDependency] = [],
        testingDependencies: [TargetDependency] = [],
        testDependencies: [TargetDependency] = [],
        hasDomain: Bool = true,
        hasData: Bool = true,
        hasTests: Bool = true,
        hasTesting: Bool = true,
        hasResources: Bool = true
    ) -> Project {
        let bundleId = "\(ProjectConfig.bundlePrefix).\(name.lowercased())"
        var targets: [Target] = []

        // MARK: Interface
        targets.append(.target(
            name: "\(name)Interface",
            destinations: ProjectConfig.destinations,
            product: .staticFramework,
            bundleId: "\(bundleId).interface",
            deploymentTargets: ProjectConfig.deploymentTarget,
            infoPlist: .default,
            sources: ["Interface/Sources/**"],
            dependencies: interfaceDependencies,
            settings: .settings(base: ProjectConfig.baseSettings)
        ))

        // MARK: Domain
        if hasDomain {
            targets.append(.target(
                name: "\(name)Domain",
                destinations: ProjectConfig.destinations,
                product: .staticFramework,
                bundleId: "\(bundleId).domain",
                deploymentTargets: ProjectConfig.deploymentTarget,
                infoPlist: .default,
                sources: ["Domain/Sources/**"],
                dependencies: [.shared] + domainDependencies,
                settings: .settings(base: ProjectConfig.baseSettings)
            ))
        }

        // MARK: Data
        if hasData {
            targets.append(.target(
                name: "\(name)Data",
                destinations: ProjectConfig.destinations,
                product: .staticFramework,
                bundleId: "\(bundleId).data",
                deploymentTargets: ProjectConfig.deploymentTarget,
                infoPlist: .default,
                sources: ["Data/Sources/**"],
                dependencies: [.target(name: "\(name)Domain"), .core] + dataDependencies,
                settings: .settings(base: ProjectConfig.baseSettings)
            ))
        }

        // MARK: Feature (Sources)
        var featureDeps: [TargetDependency] = [
            .target(name: "\(name)Interface"),
            .designSystem,
            .shared
        ]
        if hasDomain {
            featureDeps.insert(.target(name: "\(name)Domain"), at: 1)
        }
        featureDeps += featureDependencies

        targets.append(.target(
            name: name,
            destinations: ProjectConfig.destinations,
            product: .staticFramework,
            bundleId: bundleId,
            deploymentTargets: ProjectConfig.deploymentTarget,
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: hasResources ? ["Resources/**"] : nil,
            dependencies: featureDeps,
            settings: .settings(base: ProjectConfig.featureSettings)
        ))

        // MARK: Testing (Mocks)
        if hasTesting {
            var testingDeps: [TargetDependency] = [
                .target(name: "\(name)Interface")
            ]
            if hasDomain {
                testingDeps.append(.target(name: "\(name)Domain"))
            }
            testingDeps += testingDependencies

            targets.append(.target(
                name: "\(name)Testing",
                destinations: ProjectConfig.destinations,
                product: .staticFramework,
                bundleId: "\(bundleId).testing",
                deploymentTargets: ProjectConfig.deploymentTarget,
                infoPlist: .default,
                sources: ["Testing/Sources/**"],
                dependencies: testingDeps,
                settings: .settings(base: ProjectConfig.baseSettings)
            ))
        }

        // MARK: Tests
        if hasTests {
            var testDeps: [TargetDependency] = [
                .target(name: name),
                .designSystem,
                .shared
            ]
            if hasTesting {
                testDeps.append(.target(name: "\(name)Testing"))
            }
            testDeps += testDependencies

            targets.append(.target(
                name: "\(name)Tests",
                destinations: ProjectConfig.destinations,
                product: .unitTests,
                bundleId: "\(bundleId).tests",
                deploymentTargets: ProjectConfig.deploymentTarget,
                infoPlist: .default,
                sources: ["Tests/**"],
                dependencies: testDeps
            ))
        }

        return Project(
            name: name,
            organizationName: ProjectConfig.organizationName,
            targets: targets
        )
    }

    /// 단일 모듈 생성 (Core, Shared, DesignSystem 등)
    static func module(
        name: String,
        dependencies: [TargetDependency] = [],
        hasResources: Bool = false,
        hasTests: Bool = false,
        resourceSynthesizers: [ResourceSynthesizer] = []
    ) -> Project {
        let bundleId = "\(ProjectConfig.bundlePrefix).\(name.lowercased())"
        var targets: [Target] = [
            .target(
                name: name,
                destinations: ProjectConfig.destinations,
                product: .staticFramework,
                bundleId: bundleId,
                deploymentTargets: ProjectConfig.deploymentTarget,
                infoPlist: .default,
                sources: ["Sources/**"],
                resources: hasResources ? ["Resources/**"] : nil,
                dependencies: dependencies,
                settings: .settings(base: ProjectConfig.baseSettings)
            )
        ]

        if hasTests {
            targets.append(.target(
                name: "\(name)Tests",
                destinations: ProjectConfig.destinations,
                product: .unitTests,
                bundleId: "\(bundleId).tests",
                deploymentTargets: ProjectConfig.deploymentTarget,
                infoPlist: .default,
                sources: ["Tests/**"],
                dependencies: [.target(name: name)]
            ))
        }

        return Project(
            name: name,
            organizationName: ProjectConfig.organizationName,
            targets: targets,
            resourceSynthesizers: resourceSynthesizers.isEmpty ? .default : resourceSynthesizers
        )
    }
}

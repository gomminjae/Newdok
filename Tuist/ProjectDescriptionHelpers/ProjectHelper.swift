import ProjectDescription

public extension Project {
    static func makeModule(
        name: String,
        organizationName: String = "Newdok",
        bundlePrefix: String = "com.newdok",
        destinations: Destinations = .iOS,
        deploymentTargets: DeploymentTargets = .iOS("17.0"),
        product: Product = .staticFramework,
        dependencies: [TargetDependency] = [],
        hasResources: Bool = true,
        hasTests: Bool = true
    ) -> Project {
        let bundleId = "\(bundlePrefix).\(name.lowercased())"

        var targets: [Target] = [
            .target(
                name: name,
                destinations: destinations,
                product: product,
                bundleId: bundleId,
                deploymentTargets: deploymentTargets,
                infoPlist: .default,
                sources: ["Sources/**"],
                resources: hasResources ? ["Resources/**"] : nil,
                dependencies: dependencies
            )
        ]

        if hasTests {
            targets.append(
                .target(
                    name: "\(name)Tests",
                    destinations: destinations,
                    product: .unitTests,
                    bundleId: "\(bundleId).tests",
                    deploymentTargets: deploymentTargets,
                    infoPlist: .default,
                    sources: ["Tests/**"],
                    dependencies: [
                        .target(name: name)
                    ]
                )
            )
        }

        return Project(
            name: name,
            organizationName: organizationName,
            targets: targets
        )
    }
}

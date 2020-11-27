// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "MBRealmKit",
	platforms: [
		.iOS(.v12),
	],
	products: [
		.library(name: "MBRealmKit",
				 targets: ["MBRealmKit"])
	],
	dependencies: [
		.package(name: "MBCommonKit",
				 url: "https://github.com/Daimler/MBSDK-CommonKit-iOS.git",
				 .upToNextMajor(from: "3.0.0")),
		.package(name: "Realm",
				 url: "https://github.com/realm/realm-cocoa",
				 .upToNextMajor(from: "10.1.0"))
	],
	targets: [
		.target(name: "MBRealmKit",
				dependencies: [
					.byName(name: "MBCommonKit"),
					.product(name: "RealmSwift", package: "Realm")
				],
				path: "MBRealmKit/MBRealmKit",
				exclude: ["Info.plist"]),
		.testTarget(name: "MBRealmKitTests",
					dependencies: ["MBRealmKit"],
					path: "MBRealmKit/MBRealmKitTests",
					exclude: ["Info.plist"])
	],
	swiftLanguageVersions: [.v5]
)

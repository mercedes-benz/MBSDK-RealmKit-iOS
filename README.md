![MBRealmKit](logo.jpg "Banner")

[![swift 5](https://img.shields.io/badge/swift-5-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![swift 5.1](https://img.shields.io/badge/swift-5.1-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![swift 5.2](https://img.shields.io/badge/swift-5.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![swift 5.3](https://img.shields.io/badge/swift-5.3-orange.svg?style=flat)](https://developer.apple.com/swift/)
![License](https://img.shields.io/cocoapods/l/MBRealmKit)
![Platform](https://img.shields.io/cocoapods/p/MBRealmKit)
![Version](https://img.shields.io/cocoapods/v/MBRealmKit)
[![swift-package-manager](https://img.shields.io/badge/SPM-compatible-brightgreen)](https://github.com/apple/swift-package-manager)

## Requirements

- Xcode 10.3 / 11.x / 12.x
- Swift 5.x
- iOS 12.0+

## Installation

### CocoaPods

MBRealmKit is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your `Podfile`:

```ruby
pod 'MBRealmKit', '~> 3.0'
```

### Swift Package Manager

MBNetworkKit is available through [Swift Package Manager](https://swift.org/package-manager/). Once you have your Swift package set up, adding MBRealmKit as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(name: "MBRealmKit",
             url: "https://github.com/Daimler/MBSDK-RealmKit-iOS.git",
			 .upToNextMajor(from: "3.0.0"))
]
```

## Intended Usage

This module handles the offline storage of the MBSDK-Modules. It caches the required data and returns it. It is possible to observe the cached data and to respond to the changes.

## Author

Daimler AG, developer@daimler.com

## License

MBRealmKit is available under the MIT license. See the LICENSE file for more info.

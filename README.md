[![Swift](https://img.shields.io/badge/Swift-5.7-blue.svg)](https://swift.org)
[![MIT](https://img.shields.io/badge/License-MIT-red.svg)](https://opensource.org/licenses/MIT)
[![Tests](https://github.com/request-dl/request-dl/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/request-dl/request-dl/actions/workflows/tests.yml)
[![Test Coverage](https://api.codeclimate.com/v1/badges/516f7228a532b73b5540/test_coverage)](https://codeclimate.com/github/brennobemoura/request-dl/test_coverage)

# RequestDL

This library came about through improvements in functionality 
and techniques of the library developed by Carson Katri called
[Request](https://github.com/carson-katri/swift-request).

Some features have been removed and others improved in an effort 
to make the code more declarative. In addition, we have gained in 
the handling of the return through the TaskModifier and TaskInterceptor 
added in this version.

## Next steps

Here's the list of what's left to finish the first version of RequestDL.

- ✅ Implement support for Combine;
- ⏳ Implement unit tests;
- ⏳ Document code;

Feel free to open PRs and implement these features. After the first 
version becomes available, we will open to implement new features.

## Installation

This repository is distributed through SPM, being possible to use it 
in two ways:

1. Xcode

In Xcode 14, go to `File > Packages > Add Package Dependency...`, then paste in 
`https://github.com/request-dl/request-dl.git`

2. Package.swift

```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "MyPackage",
    products: [
        .library(
            name: "MyPackage",
            targets: ["MyPackage"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/request-dl/request-dl.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "MyPackage",
            dependencies: ["RequestDL"]
        )
    ]
)
```

## Usage

This is a preliminary example that shows how to use RequestDL 
in applications.

```swift
func requestGoogle() async throws -> GoogleResponse {
    try await DataTask {
        BaseURL("google.com")
        
        HeaderGroup {
            Headers.Accept(.json)
            Headers.ContentType(.json)
        }
        
        Query("apple", forKey: "q")
    }
    .logInConsole(true)
    .decode(GoogleResponse.self)
    .ignoreResponse()
    .response()
}
```

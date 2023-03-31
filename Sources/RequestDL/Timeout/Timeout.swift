/*
 See LICENSE for this package's licensing information.
*/

import Foundation

/**
 `Timeout` is a struct that defines the request timeout for a resource and request.

 Usage:

 To create an instance of `Timeout`, initialize it with the time interval and which source to be limited.

 ```swift
 Timeout(40, for: .request)
 ```

 In the example below, a request is made to Google's website with the timeout for all types.

 ```swift
 DataTask {
     BaseURL("google.com")
     Timeout(60, for: .all)
 }

 ```

 - Note: A request timeout is the amount of time a client will wait for a response from the server
 before terminating the connection. The timeout parameter is the duration of time before the timeout
 occurs, and the source parameter specifies the type of timeout to be applied
 */
public struct Timeout: Property {

    public typealias Body = Never

    let timeout: UnitTime
    let source: Source

    public init(_ timeout: UnitTime, for source: Source = .all) {
        self.timeout = timeout
        self.source = source
    }

    /**
     Initializes a new instance of `Timeout`.

     - Parameters:
        - timeout: The duration of time before the timeout occurs.
        - source: The type of timeout to be applied.

     - Returns: A new instance of `Timeout`.

     - Note: By default, the `source` parameter is set to `.all`.

     */
    @available(*, deprecated, renamed: "init(_:for:)")
    public init(_ timeout: TimeInterval, for source: Source = .all) {
        self.init(
            UnitTime.nanoseconds(Int64(floor(timeout * 1_000_000_000))),
            for: source
        )
    }

    /// Returns an exception since `Never` is a type that can never be constructed.
    public var body: Never {
        bodyException()
    }
}

extension Timeout {

    private struct Node: PropertyNode {

        let timeout: UnitTime
        let source: Source

        func make(_ make: inout Make) async throws {
            let timeout = TimeInterval(Double(timeout.nanoseconds) / 1_000_000_000)

            if source.contains(.connect) {
                make.configuration.timeoutIntervalForRequest = timeout
            }

            if source.contains(.read) {
                make.configuration.timeoutIntervalForResource = timeout
            }
        }
    }

    public static func _makeProperty(
        property: _GraphValue<Timeout>,
        inputs: _PropertyInputs
    ) async throws -> _PropertyOutputs {
        _ = inputs[self]
        return .init(Leaf(Node(
            timeout: property.timeout,
            source: property.source
        )))
    }
}

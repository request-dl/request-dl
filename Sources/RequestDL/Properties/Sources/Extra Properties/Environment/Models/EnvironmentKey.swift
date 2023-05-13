/*
 See LICENSE for this package's licensing information.
*/

import Foundation

/**
 The `EnvironmentKey` protocol defines a type that can be used as a key to
 retrieve an `Value` from `EnvironmentValues`.
 */
public protocol EnvironmentKey: Sendable {

    associatedtype Value: Sendable

    /// The default value for this `EnvironmentKey`.
    static var defaultValue: Value { get }
}

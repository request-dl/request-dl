/*
 See LICENSE for this package's licensing information.
*/

import Foundation

protocol StreamProtocol<Value>: AnyObject, Sendable {

    associatedtype Value: Sendable

    var isOpen: Bool { get }

    func append(_ value: Result<Value?, Error>)

    func next() throws -> Value?
}

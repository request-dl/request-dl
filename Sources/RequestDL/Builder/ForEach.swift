/*
 See LICENSE for this package's licensing information.
*/

import Foundation

/**
 A request that iterates over a collection of data and creates a request for each element.

 You can use this request to dynamically generate requests based on a collection of data.

 Example:

 ```swift
 let paths = ["user", "search", "results"]

 DataTask {
     BaseURL("ecommerce.com")
     ForEach(paths) {
         Path($0)
     }
 }
 ```
 */
public struct ForEach<Data, ID, Content>: Property where Data: Sequence, ID: Hashable, Content: Property {

    public let data: Data

    public let content: (Data.Element) -> Content

    enum IDSource {
        case keyPath(KeyPath<Data.Element, ID>)
        case uuid(() -> ID)
    }

    private let id: IDSource

    private var abstractContent: Content {
        fatalError(
            """
            There was an attempt to access a variable for which access was not expected.
            """
        )
    }

    public init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @PropertyBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.id = .keyPath(id)
        self.content = content
    }

    /**
     Initializes the `ForEach` request with collection of data provided.

     - Parameters:
         - data: The collection of data to iterate over.
         - content: A closure that creates a content for each element of the collection.
     */
    @available(*, deprecated, renamed: "init(_:id:content:)")
    public init(
        _ data: Data,
        @PropertyBuilder content: @escaping (Data.Element) -> Content
    ) where ID == UUID {
        self.data = data
        self.id = .uuid { UUID() }
        self.content = content
    }

    /// Returns an exception since `Never` is a type that can never be constructed.
    public var body: Never {
        bodyException()
    }
}

extension ForEach {

    /// This method is used internally and should not be called directly.
    public static func _makeProperty(
        property: _GraphValue<ForEach<Data, ID, Content>>,
        inputs: _PropertyInputs
    ) async throws -> _PropertyOutputs {
        var group = ChildrenNode()

        for element in property.data {
            let id: ID

            switch property.id {
            case .keyPath(let keyPath):
                id = element[keyPath: keyPath]
            case .uuid(let factory):
                id = factory()
            }

            let output = try await Content._makeProperty(
                property: property.dynamic {
                    $0.content(element)
                },
                inputs: inputs[self, id, \.abstractContent]
            )

            group.append(output.node)
        }

        return .init(group)
    }
}

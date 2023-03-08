//
//  URLRequestRepresentable.swift
//
//  MIT License
//
//  Copyright (c) RequestDL
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

/**
 A type that represents an object that can update a URLRequest.

 You can conform to this protocol to add or modify headers, set HTTP methods, and provide other customizations
 to the URLRequest for a network task.

 Usage:

 ```swift
 struct CustomHeader: URLRequestRepresentable {
     func updateRequest(_ request: inout URLRequest) {
         request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
     }
 }
 ```
 */
public protocol URLRequestRepresentable: Property where Body == Never {

    /**
     Update the URLRequest to be used in a network task.

     - Parameter request: The `URLRequest` to be updated.
     */
    func updateRequest(_ request: inout URLRequest)
}

extension URLRequestRepresentable {

    /// Returns an exception since `Never` is a type that can never be constructed.
    public var body: Never {
        bodyException()
    }

    /// This method is used internally and should not be called directly.
    public static func makeProperty(
        _ property: Self,
        _ context: Context
    ) async {
        let node = Node(
            root: context.root,
            object: URLRequestRepresentableObject(property.updateRequest(_:)),
            children: []
        )

        context.append(node)
    }
}

struct URLRequestRepresentableObject: NodeObject {

    private let update: (inout URLRequest) -> Void

    init(_ update: @escaping (inout URLRequest) -> Void) {
        self.update = update
    }

    func makeProperty(_ make: Make) {
        update(&make.request)
    }
}

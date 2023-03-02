//
//  QueryGroup.swift
//
//  MIT License
//
//  Copyright (c) 2022 RequestDL
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

public struct QueryGroup<Content: Request>: Request {

    public typealias Body = Never

    let parameter: Content

    public init(@RequestBuilder parameter: () -> Content) {
        self.parameter = parameter()
    }

    public var body: Never {
        Never.bodyException()
    }

    public static func makeRequest(_ request: QueryGroup<Content>, _ context: Context) async {
        let node = Node(
            root: context.root,
            object: EmptyObject(request),
            children: []
        )

        let newContext = Context(node)
        await Content.makeRequest(request.parameter, newContext)

        let parameters = newContext.findCollection(Query.Object.self).map {
            ($0.key, $0.value)
        }

        context.append(Node(
            root: context.root,
            object: Object(parameters),
            children: []
        ))
    }
}

extension QueryGroup where Content == ForEach<[String: Any], Query> {

    public init(_ dictionary: [String: Any]) {
        self.init {
            ForEach(dictionary) {
                Query($0.value, forKey: $0.key)
            }
        }
    }
}

extension QueryGroup {

    struct Object: NodeObject {

        private let parameters: [(String, String)]

        init(_ parameters: [(String, String)]) {
            self.parameters = parameters
        }

        func makeRequest(_ configuration: RequestConfiguration) {
            guard
                let url = configuration.request.url,
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            else { return }

            var queryItems = components.queryItems ?? []

            for (key, value) in parameters {
                queryItems.append(.init(name: key, value: value))
            }

            components.queryItems = queryItems

            configuration.request.url = components.url ?? url
        }
    }
}

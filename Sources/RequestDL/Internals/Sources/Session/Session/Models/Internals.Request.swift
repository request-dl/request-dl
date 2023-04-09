/*
 See LICENSE for this package's licensing information.
*/

import NIOCore
import AsyncHTTPClient

extension Internals {

    struct Request {

        var url: String
        var method: String?
        var headers: Headers
        var body: Body?

        init(url: String) {
            self.url = url
            self.method = nil
            self.headers = .init()
            self.body = nil
        }
    }
}

extension Internals.Request {

    func build() throws -> HTTPClient.Request {
        try HTTPClient.Request(
            url: url,
            method: method.map { .init(rawValue: $0) } ?? .GET,
            headers: headers.build(),
            body: body?.build()
        )
    }
}

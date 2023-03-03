//
//  Headers.Host.swift
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

extension Headers {

    public struct Host: Request {

        private let value: Any

        public init<Host, Port>(
            _ host: Host,
            port: Port
        ) where Host: StringProtocol, Port: StringProtocol {
            self.value = "\(host)\(port)"
        }

        public init<S: StringProtocol>(_ host: S) {
            self.value = host
        }

        /// Returns an exception since `Never` is a type that can never be constructed.
        public var body: Never {
            Never.bodyException()
        }
    }
}

extension Headers.Host: PrimitiveRequest {

    func makeObject() -> Headers.Object {
        .init(value, forKey: "Host")
    }
}

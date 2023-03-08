//
//  HeadersRefererTests.swift
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

import XCTest
@testable import RequestDL

final class HeadersRefererTests: XCTestCase {

    func testReferer() async throws {
        let property = TestProperty(Headers.Referer("https://www.example.com/"))
        let (_, request) = await resolve(property)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Referer"), "https://www.example.com/")
    }

    func testRefererWithHTML() async throws {
        let property = TestProperty(Headers.Referer("https://www.example.com/page1.html"))
        let (_, request) = await resolve(property)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Referer"), "https://www.example.com/page1.html")
    }

    func testRefererWithPathAndQuery() async throws {
        let property = TestProperty(Headers.Referer("https://www.google.com/search?q=apple"))
        let (_, request) = await resolve(property)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Referer"), "https://www.google.com/search?q=apple")
    }

    func testNeverBody() async throws {
        // Given
        let type = Headers.Referer.self

        // Then
        XCTAssertTrue(type.Body.self == Never.self)
    }
}

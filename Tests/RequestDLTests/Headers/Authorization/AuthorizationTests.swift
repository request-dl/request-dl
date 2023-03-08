//
//  AuthorizationTests.swift
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

final class AuthorizationTests: XCTestCase {

    func testAuthorizationWithTypeAndToken() async {
        // Given
        let auth = Authorization(.bearer, token: "myToken")

        // When
        let (_, request) = await resolve(TestProperty(auth))

        // Then
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer myToken")
    }

    func testAuthorizationWithUsernameAndPassword() async {
        let auth = Authorization(username: "myUser", password: "myPassword")

        // When
        let (_, request) = await resolve(TestProperty(auth))

        // Then
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Basic bXlVc2VyOm15UGFzc3dvcmQ=")
    }

    func testNeverBody() async throws {
        // Given
        let type = Authorization.self

        // Then
        XCTAssertTrue(type.Body.self == Never.self)
    }
}

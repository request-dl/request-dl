//
//  RequestBuilder.swift
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

@resultBuilder
public struct RequestBuilder {

    public static func buildBlock() -> EmptyRequest {
        EmptyRequest()
    }

    public static func buildBlock<Content: Request>(_ component: Content) -> Content {
        component
    }

    public static func buildIf<Content: Request>(_ content: Content?) -> _OptionalRequest<Content> {
        _OptionalRequest(content)
    }

    public static func buildEither<
        TrueRequest: Request,
        FalseRequest: Request
    >(first: TrueRequest) -> _ConditionalRequest<TrueRequest, FalseRequest> {
        _ConditionalRequest(trueRequest: first)
    }

    public static func buildEither<
        TrueRequest: Request,
        FalseRequest: Request
    >(second: FalseRequest) -> _ConditionalRequest<TrueRequest, FalseRequest> {
        _ConditionalRequest(falseRequest: second)
    }

    public static func buildLimitedAvailability<Content: Request>(_ component: Content) -> Content {
        component
    }
}

// swiftlint:disable function_parameter_count identifier_name large_tuple
extension RequestBuilder {

    public static func buildBlock<
        C0: Request,
        C1: Request
    >(
        _ c0: C0,
        _ c1: C1
    ) -> _TupleRequest<(C0, C1)> {
        _TupleRequest {
            await C0.makeRequest(c0, $0)
            await C1.makeRequest(c1, $0)
        }
    }

    public static func buildBlock<
        C0: Request,
        C1: Request,
        C2: Request
    >(
        _ c0: C0,
        _ c1: C1,
        _ c2: C2
    ) -> _TupleRequest<(C0, C1, C2)> {
        _TupleRequest {
            await C0.makeRequest(c0, $0)
            await C1.makeRequest(c1, $0)
            await C2.makeRequest(c2, $0)
        }
    }

    public static func buildBlock<
        C0: Request,
        C1: Request,
        C2: Request,
        C3: Request
    >(
        _ c0: C0,
        _ c1: C1,
        _ c2: C2,
        _ c3: C3
    ) -> _TupleRequest<(C0, C1, C2, C3)> {
        _TupleRequest {
            await C0.makeRequest(c0, $0)
            await C1.makeRequest(c1, $0)
            await C2.makeRequest(c2, $0)
            await C3.makeRequest(c3, $0)
        }
    }

    public static func buildBlock<
        C0: Request,
        C1: Request,
        C2: Request,
        C3: Request,
        C4: Request
    >(
        _ c0: C0,
        _ c1: C1,
        _ c2: C2,
        _ c3: C3,
        _ c4: C4
    ) -> _TupleRequest<(C0, C1, C2, C3, C4)> {
        _TupleRequest {
            await C0.makeRequest(c0, $0)
            await C1.makeRequest(c1, $0)
            await C2.makeRequest(c2, $0)
            await C3.makeRequest(c3, $0)
            await C4.makeRequest(c4, $0)
        }
    }

    public static func buildBlock<
        C0: Request,
        C1: Request,
        C2: Request,
        C3: Request,
        C4: Request,
        C5: Request
    >(
        _ c0: C0,
        _ c1: C1,
        _ c2: C2,
        _ c3: C3,
        _ c4: C4,
        _ c5: C5
    ) -> _TupleRequest<(C0, C1, C2, C3, C4, C5)> {
        _TupleRequest {
            await C0.makeRequest(c0, $0)
            await C1.makeRequest(c1, $0)
            await C2.makeRequest(c2, $0)
            await C3.makeRequest(c3, $0)
            await C4.makeRequest(c4, $0)
            await C5.makeRequest(c5, $0)
        }
    }

    public static func buildBlock<
        C0: Request,
        C1: Request,
        C2: Request,
        C3: Request,
        C4: Request,
        C5: Request,
        C6: Request
    >(
        _ c0: C0,
        _ c1: C1,
        _ c2: C2,
        _ c3: C3,
        _ c4: C4,
        _ c5: C5,
        _ c6: C6
    ) -> _TupleRequest<(C0, C1, C2, C3, C4, C5, C6)> {
        _TupleRequest {
            await C0.makeRequest(c0, $0)
            await C1.makeRequest(c1, $0)
            await C2.makeRequest(c2, $0)
            await C3.makeRequest(c3, $0)
            await C4.makeRequest(c4, $0)
            await C5.makeRequest(c5, $0)
            await C6.makeRequest(c6, $0)
        }
    }

    public static func buildBlock<
        C0: Request,
        C1: Request,
        C2: Request,
        C3: Request,
        C4: Request,
        C5: Request,
        C6: Request,
        C7: Request
    >(
        _ c0: C0,
        _ c1: C1,
        _ c2: C2,
        _ c3: C3,
        _ c4: C4,
        _ c5: C5,
        _ c6: C6,
        _ c7: C7
    ) -> _TupleRequest<(C0, C1, C2, C3, C4, C5, C6, C7)> {
        _TupleRequest {
            await C0.makeRequest(c0, $0)
            await C1.makeRequest(c1, $0)
            await C2.makeRequest(c2, $0)
            await C3.makeRequest(c3, $0)
            await C4.makeRequest(c4, $0)
            await C5.makeRequest(c5, $0)
            await C6.makeRequest(c6, $0)
            await C7.makeRequest(c7, $0)
        }
    }
}

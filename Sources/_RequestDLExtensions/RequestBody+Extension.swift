/*
 See LICENSE for this package's licensing information.
*/

import Foundation
import NIOCore
import NIOPosix
import AsyncHTTPClient
@testable import RequestDLInternals

extension RequestBody {

    public func data() async throws -> Data {
        try await buffers().resolveData().reduce(Data(), +)
    }

    public func buffers() async throws -> [DataBuffer] {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let eventLoop = group.any()

        var buffers: [DataBuffer] = []

        try await build().stream(.init(closure: {
            switch $0 {
            case .byteBuffer(var byteBuffer):
                if let data = byteBuffer.readData(length: byteBuffer.readableBytes) {
                    buffers.append(.init(data))
                }
            case .fileRegion:
                fatalError()
            }

            return eventLoop.makeSucceededVoidFuture()
        })).get()

        return buffers
    }
}

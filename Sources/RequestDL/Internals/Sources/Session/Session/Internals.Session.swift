/*
 See LICENSE for this package's licensing information.
*/

import Foundation
import AsyncHTTPClient
import NIOCore
import NIOPosix

class SessionTask {

    let response: Internals.AsyncResponse
    private var payload: (HTTPClient, EventLoopFuture<Void>)?
    private var complete: Bool = false

    init(_ response: Internals.AsyncResponse) {
        self.response = response
    }

    func attach(_ client: HTTPClient, _ eventLoopFuture: EventLoopFuture<Void>) {
        payload = (client, eventLoopFuture.always { [weak self] _ in
            self?.complete = true
        })
    }

    func shutdown() {
        guard let (client, promise) = payload else {
            return
        }

        self.payload = nil

        _Concurrency.Task {
            try? await promise.get()
            try? await client.shutdown()
        }
    }

    deinit {
        if complete {
            try? payload?.0.syncShutdown()
        } else {
            shutdown()
        }
    }
}

extension Internals {

    struct Session {

        private let client: (Internals.Session.Configuration) async throws -> HTTPClient
        var configuration: Internals.Session.Configuration

        init(
            provider: Provider,
            configuration: Configuration
        ) async throws {
            self.configuration = configuration

            client = { configuration in
                await EventLoopGroupManager.shared.client(
                    id: provider.id,
                    factory: { provider.build() },
                    configuration: try configuration.build()
                )
            }
        }

        func request(_ request: Request) async throws -> SessionTask {
            let upload = DataStream<Int>()
            let head = DataStream<ResponseHead>()
            let download = DownloadBuffer(readingMode: configuration.readingMode)

            let delegate = ClientResponseReceiver(
                url: request.url,
                upload: upload,
                head: head,
                download: download
            )

            let response = AsyncResponse(
                upload: upload,
                head: head,
                download: download.stream
            )

            let request = try request.build()
            let client = try await client(configuration)

            let eventLoopFuture = client.execute(
                request: request,
                delegate: delegate
            ).futureResult

            let sessionTask = SessionTask(response)
            sessionTask.attach(client, eventLoopFuture)
            return sessionTask
        }
    }
}

extension Internals.Session {

    enum Provider {
        case shared
        case identifier(String, numberOfThreads: Int = 1)
        case custom(EventLoopGroup)
    }
}

extension Internals.Session.Provider {

    var id: String {
        switch self {
        case .shared:
            return "\(ObjectIdentifier(MultiThreadedEventLoopGroup.shared))"
        case .identifier(let id, let numberOfThreads):
            return "\(id).\(numberOfThreads)"
        case .custom(let eventLoopGroup):
            return "\(ObjectIdentifier(eventLoopGroup))"
        }
    }

    func build() -> EventLoopGroup {
        switch self {
        case .shared:
            return MultiThreadedEventLoopGroup.shared
        case .identifier(_, let numberOfThreads):
            return MultiThreadedEventLoopGroup(numberOfThreads: numberOfThreads)
        case .custom(let eventLoopGroup):
            return eventLoopGroup
        }
    }
}

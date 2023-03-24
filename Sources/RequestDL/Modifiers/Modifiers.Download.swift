/*
 See LICENSE for this package's licensing information.
*/

import Foundation

extension Modifiers {

    public struct Download<Content: Task, Output>: TaskModifier {

        let progress: (Data, Int?) -> Void

        let data: (Content.Element) -> (Int?, AsyncBytes)
        let output: (Content.Element, Data) -> Output

        public func task(_ task: Content) async throws -> Output {
            let result = try await task.result()

            let (contentLength, bytes) = data(result)

            var data = Data()

            for try await byte in bytes {
                data.append(byte)
                progress(byte, contentLength)
            }

            return output(result, data)
        }
    }
}

extension Task<TaskResult<AsyncBytes>> {

    public func download(
        _ contentLengthKey: String? = "content-length",
        _ progress: @escaping (Data, Int?) -> Void
    ) -> ModifiedTask<Modifiers.Download<Self, TaskResult<Data>>> {
        modify(Modifiers.Download(
            progress: progress,
            data: { result in
                (
                    contentLengthKey
                        .flatMap { result.head.headers[$0] }
                        .flatMap(Int.init),
                    result.payload
                )
            },
            output: {
                .init(
                    head: $0.head,
                    payload: $1
                )
            }
        ))
    }
}

extension Task<AsyncBytes> {

    public func download(
        _ contentLength: Int?,
        _ progress: @escaping (Data, Int?) -> Void
    ) -> ModifiedTask<Modifiers.Download<Self, Data>> {
        modify(Modifiers.Download(
            progress: progress,
            data: { (contentLength, $0) },
            output: { $1 }
        ))
    }
}

import Foundation

extension Modifiers {

    public struct FlatMapError<Content: Task>: TaskModifier {

        public typealias Element = Content.Element

        let flatMapErrorHandler: (Error) throws -> Void

        init(flatMapErrorHandler: @escaping (Error) throws -> Void) {
            self.flatMapErrorHandler = flatMapErrorHandler
        }

        public func task(_ task: Content) async throws -> Element {
            do {
                return try await task.response()
            } catch {
                try flatMapErrorHandler(error)
                throw error
            }
        }
    }
}

extension Task {

    public func flatMapError(
        _ flatMapErrorHandler: @escaping (Error) throws -> Void
    ) -> ModifiedTask<Modifiers.FlatMapError<Self>> {
        modify(Modifiers.FlatMapError(flatMapErrorHandler: flatMapErrorHandler))
    }

    public func flatMapError<Failure: Error>(
        _ type: Failure.Type,
        _ flatMapErrorHandler: @escaping (Failure) throws -> Void
    ) -> ModifiedTask<Modifiers.FlatMapError<Self>> {
        flatMapError {
            if let error = $0 as? Failure {
                try flatMapErrorHandler(error)
            }
        }
    }
}

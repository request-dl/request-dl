/*
 See LICENSE for this package's licensing information.
*/

import XCTest
@testable import RequestDL

class InternalsAnyStreamTests: XCTestCase {

    final class StreamMock: StreamProtocol {

        private let _value = SendableBox<Result<Int, Error>?>(nil)
        private let _isOpen = SendableBox<Bool>(true)

        var value: Result<Int, Error>? {
            get { _value() }
            set { _value(newValue) }
        }

        var isOpen: Bool {
            get { _isOpen() }
            set { _isOpen(newValue) }
        }

        func append(_ value: Result<Int?, Error>) {
            switch value {
            case .success(let value):
                if let value = value {
                    self.value = .success(value)
                } else {
                    isOpen = false
                }
            case .failure(let error):
                self.value = .failure(error)
            }
        }

        func next() throws -> Int? {
            switch value {
            case .failure(let error):
                throw error
            case .success(let value):
                return value
            case .none:
                return nil
            }
        }
    }

    var mock: StreamMock!

    override func setUp() async throws {
        try await super.setUp()
        mock = .init()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        mock = nil
    }

    func testAnyStream_whenCloseMock_shouldIsOpenBeFalse() async throws {
        // Given
        let isOpen = false

        // When
        let sut = Internals.AnyStream(mock)
        sut.append(.success(nil))

        // Then
        XCTAssertEqual(sut.isOpen, mock.isOpen)
        XCTAssertEqual(sut.isOpen, isOpen)
    }

    func testAnyStream_whenInitMock_shouldIsOpenBeTrue() async throws {
        // Given
        let isOpen = true

        // When
        let sut = Internals.AnyStream(mock)

        // Then
        XCTAssertEqual(sut.isOpen, mock.isOpen)
        XCTAssertEqual(sut.isOpen, isOpen)
    }

    func testAnyStream_whenAppendValue_shouldNextBeValid() async throws {
        // Given
        let value = 1

        // When
        let sut = Internals.AnyStream(mock)
        sut.append(.success(value))

        // Then
        XCTAssertEqual(try sut.next(), try mock.value?.get())
        XCTAssertEqual(try mock.value?.get(), value)
    }

    func testAnyStream_whenAppendError_shouldThrowError() async throws {
        // When
        let sut = Internals.AnyStream(mock)
        sut.append(.failure(AnyError()))

        // Then
        XCTAssertThrowsError(try sut.next())
        XCTAssertThrowsError(try mock.value?.get())
    }
}

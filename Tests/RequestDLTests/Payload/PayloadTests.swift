/*
 See LICENSE for this package's licensing information.
*/

import XCTest
import _RequestDLExtensions
@testable import RequestDL

final class PayloadTests: XCTestCase {

    struct Mock: Codable {
        let foo: String
        let date: Date
    }

    func testDictionaryPayload() async throws {
        // Given
        let dictionary: [String: Any] = [
            "foo": "bar",
            "number": 123
        ]

        let options = JSONSerialization.WritingOptions([.withoutEscapingSlashes])

        // When
        let property = TestProperty(Payload(dictionary, options: options))
        let (_, request) = try await resolve(property)

        let expectedPayload = _DictionaryPayload(dictionary, options: options)
        let payload = try await request.body?.data()

        // Then
        XCTAssertEqual(payload, expectedPayload.data)
    }

    func testStringPayload() async throws {
        // Given
        let foo = "foo"
        let encoding = String.Encoding.utf8

        // When
        let property = TestProperty(Payload(foo, using: encoding))
        let (_, request) = try await resolve(property)

        let expectedPayload = _StringPayload(foo, using: encoding)
        let payload = try await request.body?.data()

        // Then
        XCTAssertEqual(payload, expectedPayload.data)
    }

    func testDataPayload() async throws {
        // Given
        let data = Data("foo,bar".utf8)

        // When
        let property = TestProperty(Payload(data))
        let (_, request) = try await resolve(property)

        let expectedPayload = _DataPayload(data)
        let payload = try await request.body?.data()

        // Then
        XCTAssertEqual(payload, expectedPayload.data)
    }

    func testEncodablePayload() async throws {
        // Given
        let mock = Mock(
            foo: "foo",
            date: Date()
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        // When
        let property = TestProperty(Payload(mock, encoder: encoder))
        let (_, request) = try await resolve(property)
        let expectedPayload = _EncodablePayload(mock, encoder: encoder)

        let expectedMock = try decoder.decode(Mock.self, from: expectedPayload.data)
        let payload = try await request.body?.data()

        // Then
        XCTAssertEqual(payload, expectedPayload.data)
        XCTAssertEqual(mock.foo, expectedMock.foo)

        XCTAssertEqual(
            mock.date.timeIntervalSince1970,
            expectedMock.date.timeIntervalSince1970
        )
    }

    func testNeverBody() async throws {
        // Given
        let property = Payload(Data())

        // Then
        try await assertNever(property.body)
    }
}

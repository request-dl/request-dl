/*
 See LICENSE for this package's licensing information.
*/

import XCTest
@testable import RequestDL

class EncodablePayloadFactoryTests: XCTestCase {

    struct Mock: Codable {
        let foo: String
        let date: Date
    }

    func testEncodablePayload() async throws {
        // Given
        let mock = Mock(
            foo: "foo",
            date: Date()
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970

        // When
        let payload = EncodablePayloadFactory(
            mock,
            encoder: encoder,
            contentType: nil
        )

        let sut = try payload().getData().map {
            try decoder.decode(Mock.self, from: $0)
        }

        // Then
        XCTAssertEqual(sut?.foo, mock.foo)

        XCTAssertEqual(
            sut?.date.seconds,
            mock.date.seconds
        )
    }
}

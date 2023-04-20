/*
 See LICENSE for this package's licensing information.
*/

import XCTest
@testable import RequestDL

final class _DataPayloadTests: XCTestCase {

    func testDataPayload() async throws {
        // Given
        let data = Data("foo".utf8)

        // When
        let payload = _DataPayload(data)

        // Then
        XCTAssertEqual(payload.buffer, Internals.DataBuffer(data))
    }
}

/*
 See LICENSE for this package's licensing information.
*/

import XCTest
@testable import RequestDLInternals

// swiftlint:disable type_body_length file_length
class FileBufferTests: XCTestCase {

    var fileURL: URL!

    override func setUp() async throws {
        try await super.setUp()

        fileURL = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("FileBufferTests.txt")

        try fileURL.removeIfNeeded()
    }

    override func tearDown() async throws {
        try await super.tearDown()

        try fileURL.removeIfNeeded()
        fileURL = nil
    }

    func testFileBuffer_whenInitURL_shouldBeEmpty() async throws {
        // Given
        let fileBuffer = FileBuffer(fileURL)

        // When
        let writerIndex = fileBuffer.writerIndex
        let readerIndex = fileBuffer.readerIndex
        let readableBytes = fileBuffer.readableBytes
        let writableBytes = fileBuffer.writableBytes
        let estimatedBytes = fileBuffer.estimatedBytes

        // Then
        XCTAssertEqual(writerIndex, .zero)
        XCTAssertEqual(readerIndex, .zero)
        XCTAssertEqual(readableBytes, .zero)
        XCTAssertEqual(writableBytes, .zero)
        XCTAssertEqual(estimatedBytes, .zero)
    }

    func testFileBuffer_whenContainsData_shouldWriterBeAtEndAndReaderAtZero() async throws {
        // Given
        let data = Data("Hello world".utf8)
        try data.write(to: fileURL)

        let fileBuffer = FileBuffer(fileURL)

        // When
        let writerIndex = fileBuffer.writerIndex
        let readerIndex = fileBuffer.readerIndex
        let readableBytes = fileBuffer.readableBytes
        let writableBytes = fileBuffer.writableBytes

        // Then
        XCTAssertEqual(writerIndex, data.count)
        XCTAssertEqual(readerIndex, .zero)
        XCTAssertEqual(readableBytes, data.count)
        XCTAssertEqual(writableBytes, .zero)
    }

    func testFileBuffer_whenContainsData_shouldReadDataAvailable() async throws {
        // Given
        let data = Data("Hello world".utf8)
        try data.write(to: fileURL)

        var fileBuffer = FileBuffer(fileURL)

        // When
        let readedData = fileBuffer.readData(data.count)

        // Then
        XCTAssertEqual(fileBuffer.writerIndex, data.count)
        XCTAssertEqual(fileBuffer.readerIndex, data.count)
        XCTAssertEqual(fileBuffer.readableBytes, .zero)
        XCTAssertEqual(fileBuffer.writableBytes, .zero)
        XCTAssertEqual(readedData, data)
        XCTAssertEqual(fileBuffer.estimatedBytes, data.count)
    }

    func testFileBuffer_whenContainsDataMovingReaderIndex_shouldReadableBytesBeUpdated() async throws {
        // Given
        let data = Data("Hello world".utf8)
        try data.write(to: fileURL)

        let index = 2
        var fileBuffer = FileBuffer(fileURL)

        // When
        let readableIndex = fileBuffer.readableBytes
        fileBuffer.moveReaderIndex(to: index)

        // Then
        XCTAssertEqual(readableIndex, data.count)
        XCTAssertEqual(fileBuffer.writerIndex, data.count)
        XCTAssertEqual(fileBuffer.readerIndex, index)
        XCTAssertEqual(fileBuffer.readableBytes, data.count - index)
        XCTAssertEqual(fileBuffer.writableBytes, .zero)
    }

    func testFileBuffer_whenContainsDataMovingWriterIndex_shouldWritableBytesBeUpdated() async throws {
        // Given
        let data = Data("Hello world".utf8)
        try data.write(to: fileURL)

        let index = data.count - 2
        var fileBuffer = FileBuffer(fileURL)

        // When
        let writableBytes = fileBuffer.writableBytes
        fileBuffer.moveWriterIndex(to: index)

        // Then
        XCTAssertEqual(writableBytes, .zero)
        XCTAssertEqual(fileBuffer.writerIndex, index)
        XCTAssertEqual(fileBuffer.readerIndex, .zero)
        XCTAssertEqual(fileBuffer.readableBytes, index)
        XCTAssertEqual(fileBuffer.writableBytes, data.count - index)
    }

    func testFileBuffer_whenWritingWithTwoCopy_shouldWritableBytesBeUpdated() async throws {
        // Given
        let data = Data("Hello World".utf8)
        let sut1 = FileBuffer(fileURL)
        var sut2 = sut1

        // When
        let writerIndex = sut1.writerIndex
        let readerIndex = sut1.readerIndex

        sut2.writeData(data)

        // Then
        XCTAssertEqual(writerIndex, sut1.writerIndex)
        XCTAssertEqual(readerIndex, sut1.readerIndex)
        XCTAssertEqual(sut2.writerIndex, data.count)
        XCTAssertEqual(sut2.readableBytes, data.count)
        XCTAssertEqual(sut1.writableBytes, data.count)
        XCTAssertEqual(sut1.readableBytes, .zero)
    }

    func testFileBuffer_whenWritingWithTwoInstances_shouldWritableBytesBeUpdated() async throws {
        // Given
        let data = Data("Hello World".utf8)
        let sut1 = FileBuffer(fileURL)
        var sut2 = FileBuffer(fileURL)

        // When
        let writerIndex = sut1.writerIndex
        let readerIndex = sut1.readerIndex

        sut2.writeData(data)

        // Then
        XCTAssertEqual(writerIndex, sut1.writerIndex)
        XCTAssertEqual(readerIndex, sut1.readerIndex)
        XCTAssertEqual(sut2.writerIndex, data.count)
        XCTAssertEqual(sut2.readableBytes, data.count)
        XCTAssertEqual(sut1.writableBytes, data.count)
        XCTAssertEqual(sut1.readableBytes, .zero)
    }

    func testFileBuffer_whenWritingWithTwoInstancesSimultaneos_shouldWritableBytesBeUpdated() async throws {
        // Given
        let data = Data("Hello World".utf8)
        let writeSliceIndex = 3
        var sut1 = FileBuffer(fileURL)
        var sut2 = FileBuffer(fileURL)

        // When
        sut2.writeData(data)
        sut1.writeData(data[0..<writeSliceIndex])

        // Then
        XCTAssertEqual(sut2.writerIndex, data.count)
        XCTAssertEqual(sut2.readableBytes, data.count)
        XCTAssertEqual(sut1.writableBytes, data.count - writeSliceIndex)
        XCTAssertEqual(sut1.readableBytes, writeSliceIndex)
    }

    func testFileBuffer_whenWritingWithTwoInstancesSimultaneosBytes_shouldWritableBytesBeUpdated() async throws {
        // Given
        let data = Data("Hello World".utf8)
        let writeSliceIndex = 3
        var sut1 = FileBuffer(fileURL)
        var sut2 = FileBuffer(fileURL)

        // When
        sut2.writeBytes(data)
        sut1.writeBytes(data[0..<writeSliceIndex])

        // Then
        XCTAssertEqual(sut2.writerIndex, data.count)
        XCTAssertEqual(sut2.readableBytes, data.count)
        XCTAssertEqual(sut1.writableBytes, data.count - writeSliceIndex)
        XCTAssertEqual(sut1.readableBytes, writeSliceIndex)
    }

    func testFileBuffer_whenReadingWithTwoCopy_shouldReadableBytesBeUpdated() async throws {
        // Given
        let data = Data("Hello World".utf8)
        try data.write(to: fileURL)

        let sut1 = FileBuffer(fileURL)
        var sut2 = sut1

        // When
        let writerIndex = sut1.writerIndex
        let readerIndex = sut1.readerIndex

        let readedData = sut2.readData(data.count)

        // Then
        XCTAssertEqual(readedData, data)
        XCTAssertEqual(writerIndex, data.count)
        XCTAssertEqual(readerIndex, .zero)
        XCTAssertEqual(sut2.writerIndex, data.count)
        XCTAssertEqual(sut2.readableBytes, .zero)
        XCTAssertEqual(sut1.writableBytes, .zero)
        XCTAssertEqual(sut1.readableBytes, data.count)
    }

    func testFileBuffer_whenReadingWithTwoInstances_shouldReadableBytesBeUpdated() async throws {
        // Given
        let data = Data("Hello World".utf8)
        try data.write(to: fileURL)

        let sut1 = FileBuffer(fileURL)
        var sut2 = FileBuffer(fileURL)

        // When
        let writerIndex = sut1.writerIndex
        let readerIndex = sut1.readerIndex

        let readedData = sut2.readData(data.count)

        // Then
        XCTAssertEqual(readedData, data)
        XCTAssertEqual(writerIndex, data.count)
        XCTAssertEqual(readerIndex, .zero)
        XCTAssertEqual(sut2.writerIndex, data.count)
        XCTAssertEqual(sut2.readableBytes, .zero)
        XCTAssertEqual(sut1.writableBytes, .zero)
        XCTAssertEqual(sut1.readableBytes, data.count)
    }

    func testFileBuffer_whenReadingWithTwoInstancesSimultaneos_shouldReadableBytesBeUpdated() async throws {
        // Given
        let data = Data("Hello World".utf8)
        try data.write(to: fileURL)

        let readSliceIndex = 3
        var sut1 = FileBuffer(fileURL)
        var sut2 = FileBuffer(fileURL)

        // When
        let readedData2 = sut2.readData(data.count)
        let readedData1 = sut1.readData(readSliceIndex)

        // Then
        XCTAssertEqual(readedData1, data[0..<readSliceIndex])
        XCTAssertEqual(sut1.writerIndex, data.count)
        XCTAssertEqual(sut1.readableBytes, data.count - readSliceIndex)
        XCTAssertEqual(sut1.writableBytes, .zero)

        XCTAssertEqual(readedData2, data)
        XCTAssertEqual(sut2.writerIndex, data.count)
        XCTAssertEqual(sut2.readableBytes, .zero)
        XCTAssertEqual(sut2.writableBytes, .zero)
    }

    func testFileBuffer_whenReadingWithTwoInstancesSimultaneosBytes_shouldReadableBytesBeUpdated() async throws {
        // Given
        let data = Data("Hello World".utf8)
        try data.write(to: fileURL)

        let readSliceIndex = 3
        var sut1 = FileBuffer(fileURL)
        var sut2 = FileBuffer(fileURL)

        // When
        let readedBytes2 = sut2.readBytes(data.count)
        let readedBytes1 = sut1.readBytes(readSliceIndex)

        // Then
        XCTAssertEqual(readedBytes1, Array(data[0..<readSliceIndex]))
        XCTAssertEqual(sut1.writerIndex, data.count)
        XCTAssertEqual(sut1.readableBytes, data.count - readSliceIndex)
        XCTAssertEqual(sut1.writableBytes, .zero)

        XCTAssertEqual(readedBytes2, Array(data))
        XCTAssertEqual(sut2.writerIndex, data.count)
        XCTAssertEqual(sut2.readableBytes, .zero)
        XCTAssertEqual(sut2.writableBytes, .zero)
    }

    func testFileBuffer_whenWritingAndReadingSimultaneos_shouldBytesBeUpdatedAndOverrided() async throws {
        // Given
        let data = Data("Hello World".utf8)
        let overrideData = Data("Earth".utf8)

        var sut1 = FileBuffer(fileURL)
        var sut2 = FileBuffer(fileURL)

        // When
        sut2.writeData(data)
        let readedDataBeforeOverride2 = sut2.readData(data.count)

        sut1.writeData(overrideData)
        let readedData2 = sut1.readData(sut1.readableBytes)

        sut2.moveReaderIndex(to: .zero)
        let readedDataAfterOverride2 = sut2.readData(sut2.readableBytes)

        // Then
        XCTAssertEqual(readedDataBeforeOverride2, data)
        XCTAssertEqual(readedData2, overrideData)
        XCTAssertEqual(readedDataAfterOverride2, overrideData + data[overrideData.count..<data.count])

        XCTAssertEqual(sut1.writerIndex, overrideData.count)
        XCTAssertEqual(sut1.readerIndex, overrideData.count)
        XCTAssertEqual(sut1.writableBytes, data.count - overrideData.count)
        XCTAssertEqual(sut1.readableBytes, .zero)

        XCTAssertEqual(sut2.writerIndex, data.count)
        XCTAssertEqual(sut2.readerIndex, data.count)
        XCTAssertEqual(sut2.writableBytes, .zero)
        XCTAssertEqual(sut2.readableBytes, .zero)
    }

    func testFileBuffer_whenWritingFromOtherFileBuffer_shouldHaveContentsAppended() async throws {
        // Given
        let otherFile = fileURL
            .deletingLastPathComponent()
            .appendingPathComponent("FileBufferOtherFile.txt")

        defer { try? otherFile.removeIfNeeded() }

        let data = Data("Hello World".utf8)
        let otherData = Data("Earth is a small planet to live".utf8)

        var sut1 = FileBuffer(fileURL)
        var sut2 = FileBuffer(otherFile)

        // When
        sut1.writeData(data)
        sut2.writeData(otherData)

        sut1.writeBuffer(&sut2)

        // Then
        XCTAssertEqual(sut1.writerIndex, data.count + otherData.count)
        XCTAssertEqual(sut2.writerIndex, otherData.count)

        XCTAssertEqual(sut1.writableBytes, .zero)
        XCTAssertEqual(sut2.writableBytes, .zero)

        XCTAssertEqual(sut1.readerIndex, .zero)
        XCTAssertEqual(sut2.readerIndex, otherData.count)

        XCTAssertEqual(sut1.readData(sut1.readableBytes), data + otherData)
    }

    func testFileBuffer_whenInitEmpty_shouldBeEmpty() async throws {
        // Given
        let fileBuffer = FileBuffer()

        // When
        let writerIndex = fileBuffer.writerIndex
        let readerIndex = fileBuffer.readerIndex
        let readableBytes = fileBuffer.readableBytes
        let writableBytes = fileBuffer.writableBytes

        // Then
        XCTAssertEqual(writerIndex, .zero)
        XCTAssertEqual(readerIndex, .zero)
        XCTAssertEqual(readableBytes, .zero)
        XCTAssertEqual(writableBytes, .zero)
    }

    func testFileBuffer_whenInitData_shouldReadContents() async throws {
        // Given
        let data = Data("Hello World".utf8)
        var fileBuffer = FileBuffer(data)

        // When
        let readedData = fileBuffer.readData(fileBuffer.readableBytes)

        // Then
        XCTAssertEqual(readedData, data)
        XCTAssertEqual(fileBuffer.writerIndex, data.count)
        XCTAssertEqual(fileBuffer.readerIndex, data.count)
        XCTAssertEqual(fileBuffer.readableBytes, .zero)
        XCTAssertEqual(fileBuffer.writableBytes, .zero)
    }

    func testFileBuffer_whenInitBytes_shouldReadContents() async throws {
        // Given
        let data = Data("Hello World".utf8)
        let bytes = Array(data)
        var fileBuffer = FileBuffer(BytesSequence(data))

        // When
        let readedBytes = fileBuffer.readBytes(fileBuffer.readableBytes)

        // Then
        XCTAssertEqual(readedBytes, bytes)
        XCTAssertEqual(fileBuffer.writerIndex, bytes.count)
        XCTAssertEqual(fileBuffer.readerIndex, bytes.count)
        XCTAssertEqual(fileBuffer.readableBytes, .zero)
        XCTAssertEqual(fileBuffer.writableBytes, .zero)
    }

    func testFileBuffer_whenInitString_shouldReadContents() async throws {
        // Given
        let string: String = "Hello World"
        var fileBuffer = FileBuffer(string)

        // When
        let readedData = fileBuffer.readData(fileBuffer.readableBytes)

        // Then
        XCTAssertEqual(readedData, Data(string.utf8))
        XCTAssertEqual(fileBuffer.writerIndex, string.count)
        XCTAssertEqual(fileBuffer.readerIndex, string.count)
        XCTAssertEqual(fileBuffer.readableBytes, .zero)
        XCTAssertEqual(fileBuffer.writableBytes, .zero)
    }

    func testFileBuffer_whenInitStaticString_shouldReadContents() async throws {
        // Given
        let string: StaticString = "Hello World"
        var fileBuffer = FileBuffer(string)

        // When
        let readedData = fileBuffer.readData(fileBuffer.readableBytes)

        // Then
        XCTAssertEqual(readedData, "\(string)".data(using: .utf8))
        XCTAssertEqual(fileBuffer.writerIndex, string.utf8CodeUnitCount)
        XCTAssertEqual(fileBuffer.readerIndex, string.utf8CodeUnitCount)
        XCTAssertEqual(fileBuffer.readableBytes, .zero)
        XCTAssertEqual(fileBuffer.writableBytes, .zero)
    }

    func testFileBuffer_whenInitFileBuffer_shouldReadContents() async throws {
        // Given
        let data = Data("Hello World".utf8)
        let fileBuffer = FileBuffer(data)
        var sut1 = FileBuffer(fileBuffer)

        // When
        let readedData = sut1.readData(sut1.readableBytes)

        // Then
        XCTAssertEqual(sut1.writerIndex, fileBuffer.writerIndex)
        XCTAssertEqual(readedData, data)
    }

    func testFileBuffer_whenInitByteURL_shouldBeEmpty() async throws {
        // Given
        let url = ByteURL()

        let fileBuffer = FileBuffer(url)

        // When
        let writerIndex = fileBuffer.writerIndex
        let readerIndex = fileBuffer.readerIndex
        let readableBytes = fileBuffer.readableBytes
        let writableBytes = fileBuffer.writableBytes

        // Then
        XCTAssertEqual(writerIndex, .zero)
        XCTAssertEqual(readerIndex, .zero)
        XCTAssertEqual(readableBytes, .zero)
        XCTAssertEqual(writableBytes, .zero)
    }

    func testFileBuffer_whenInitDataBuffer_shouldBeEqual() async throws {
        // Given
        let data = Data.randomData(length: 1_000_000)
        let dataBuffer = FileBuffer(DataBuffer(data))

        // When
        let writerIndex = dataBuffer.writerIndex
        let readerIndex = dataBuffer.readerIndex
        let readableBytes = dataBuffer.readableBytes
        let writableBytes = dataBuffer.writableBytes

        // Then
        XCTAssertEqual(writerIndex, data.count)
        XCTAssertEqual(readerIndex, .zero)
        XCTAssertEqual(readableBytes, data.count)
        XCTAssertEqual(writableBytes, .zero)
    }

    func testFileBuffer_whenReadZeroBytes_shouldBeNil() async throws {
        // Given
        var dataBuffer = FileBuffer()

        // When
        let data = dataBuffer.readData(.zero)

        // Then
        XCTAssertNil(data)
    }
}

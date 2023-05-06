/*
 See LICENSE for this package's licensing information.
*/

import Foundation

extension URLEncoder {

    public enum DateEncodingStrategy: Sendable {

        case secondsSince1970

        case millisecondsSince1970

        case iso8601

        case formatter(DateFormatter)

        case custom(@Sendable (Date, Encoder) throws -> Void)
    }
}

extension URLEncoder.DateEncodingStrategy: URLSingleEncodingStrategy {

    func encode(_ date: Date, in encoder: URLEncoder.Encoder) throws {
        switch self {
        case .secondsSince1970:
            try encodeSecondsSince1970(date, in: encoder)
        case .millisecondsSince1970:
            try encodeMillisecondsSince1970(date, in: encoder)
        case .iso8601:
            try encodeISO8601(date, in: encoder)
        case .formatter(let dateFormatter):
            try encodeDateFormatter(date, in: encoder, with: dateFormatter)
        case .custom(let closure):
            try closure(date, encoder)
        }
    }
}

private extension URLEncoder.DateEncodingStrategy {

    func encodeSecondsSince1970(_ date: Date, in encoder: URLEncoder.Encoder) throws {
        var container = encoder.valueContainer()
        try container.encode("\(Int64(date.timeIntervalSince1970))")
    }

    func encodeMillisecondsSince1970(_ date: Date, in encoder: URLEncoder.Encoder) throws {
        var container = encoder.valueContainer()
        try container.encode("\(Int64(date.timeIntervalSince1970) * 1_000)")
    }

    func encodeISO8601(_ date: Date, in encoder: URLEncoder.Encoder) throws {
        let dateFormatter = ISO8601DateFormatter()

        var container = encoder.valueContainer()
        try container.encode(dateFormatter.string(from: date))
    }

    func encodeDateFormatter(
        _ date: Date,
        in encoder: URLEncoder.Encoder,
        with dateFormatter: DateFormatter
    ) throws {
        var container = encoder.valueContainer()
        try container.encode(dateFormatter.string(from: date))
    }
}


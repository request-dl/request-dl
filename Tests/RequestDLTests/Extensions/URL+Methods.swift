/*
 See LICENSE for this package's licensing information.
*/

import Foundation

extension URL {

    var normalizePath: String {
        let rawPath = pathComponents
            .map { $0.trimmingCharacters(in: .init(charactersIn: "/")) }
            .joined(separator: "/")

        return rawPath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? rawPath
    }

    func appending(_ path: String, extension: String? = nil) -> URL {
        var url = appendingPathComponent(path)

        if let `extension` {
            url.appendPathExtension(`extension`)
        }

        return url
    }
}

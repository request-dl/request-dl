/*
 See LICENSE for this package's licensing information.
*/

import Foundation

/**
 A representation of a client certificate that can be used in an HTTP request.

 This type conforms to the `Property` protocol, which means it can be used as a property in a
 `RequestBuilder`. It has two initializers, one that takes the certificate data and password as parameters,
 and another that takes the certificate name, bundle, and password.
 */
public struct ClientCertificate: Property {

    private let source: Source
    private let password: String

    /**
     Creates a new instance of ClientCertificate with the given certificate URL and password.

     - Parameters:
        - url: The URL of the certificate.
        - password: The password to access the certificate.
     */
    public init(_ url: URL, password: String) {
        self.source = .url(url)
        self.password = password
    }

    /**
     Creates a new instance of ClientCertificate with the given certificate name, bundle, and password.

     - Parameters:
        - name: The name of the certificate.
        - bundle: The bundle in which the certificate is located.
        - password: The password to access the certificate.
     */
    public init(name: String, in bundle: Bundle, password: String) {
        self.source = .bundle(name, bundle)
        self.password = password
    }

    /// Returns an exception since `Never` is a type that can never be constructed.
    public var body: Never {
        bodyException()
    }
}

extension ClientCertificate: PrimitiveProperty {

    struct Object: NodeObject {

        private let source: ClientCertificate.Source
        private let password: String

        fileprivate init(_ source: ClientCertificate.Source, password: String) {
            self.source = source
            self.password = password
        }

        func makeProperty(_ make: Make) {
            make.delegate.onDidReceiveChallenge {
                receivedChallenge($0)
            }
        }
    }

    func makeObject() -> Object {
        Object(source, password: password)
    }
}

private extension ClientCertificate.Object {

    func receivedChallenge(
        _ challenge: URLAuthenticationChallenge
    ) -> DelegateProxy.ChallengeCredential {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate else {
            return (.rejectProtectionSpace, nil)
        }

        guard
            let url = source.url,
            let data = try? Data(contentsOf: url, options: .mappedIfSafe),
            let descriptor = PKCS12Descriptor(data, password: password),
            let certificate = descriptor.certificates.first
        else {
            fatalError("An error occurred while attempting to import the PKCS12 data using SecPKCS12Import.")
        }

        let credentials = URLCredential(
            identity: certificate.identity,
            certificates: certificate.chain,
            persistence: .forSession
        )

        return (.useCredential, credentials)
    }
}

extension ClientCertificate {

    fileprivate enum Source {
        case url(URL)
        case bundle(String, Bundle)
    }
}

extension ClientCertificate.Source {

    fileprivate var url: URL? {
        switch self {
        case .url(let url):
            return url
        case .bundle(let resource, let bundle):
            return bundle.resolveURL(forResourceName: resource)
        }
    }
}

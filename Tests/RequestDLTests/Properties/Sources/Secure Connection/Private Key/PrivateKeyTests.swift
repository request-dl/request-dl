/*
 See LICENSE for this package's licensing information.
*/

import XCTest
@testable import RequestDL

class PrivateKeyTests: XCTestCase {

    func testPrivateKey_whenInitPEMFileNoPassword_shouldBeValid() async throws {
        // Given
        let resource = Certificates(.pem).client()

        // When
        let (session, _) = try await resolve(TestProperty {
            RequestDL.SecureConnection {
                RequestDL.PrivateKey(resource.privateKeyURL.absolutePath(percentEncoded: false), format: .pem)
            }
        })

        // Then
        XCTAssertEqual(
            session.configuration.secureConnection?.privateKey,
            .file(resource.privateKeyURL.absolutePath(percentEncoded: false))
        )
    }

    func testPrivateKey_whenInitDERFileNoPassword_shouldBeValid() async throws {
        // Given
        let resource = Certificates(.der).client()

        // When
        let (session, _) = try await resolve(TestProperty {
            RequestDL.SecureConnection {
                RequestDL.PrivateKey(resource.privateKeyURL.absolutePath(percentEncoded: false), format: .der)
            }
        })

        // Then
        XCTAssertEqual(
            session.configuration.secureConnection?.privateKey,
            .privateKey(Internals.PrivateKey(
                resource.privateKeyURL.absolutePath(percentEncoded: false),
                format: .der
            ))
        )
    }

    func testPrivateKey_whenInitPEMFileWithPassword_shouldBeValid() async throws {
        // Given
        let resource = Certificates(.pem).client(password: true)
        let password = Array(Data("password".utf8))

        // When
        let (session, _) = try await resolve(TestProperty {
            RequestDL.SecureConnection {
                RequestDL.PrivateKey(resource.privateKeyURL.absolutePath(percentEncoded: false), format: .pem) {
                    $0(password)
                }
            }
        })

        // Then
        XCTAssertEqual(
            session.configuration.secureConnection?.privateKey,
            .privateKey(Internals.PrivateKey(resource.privateKeyURL.absolutePath(percentEncoded: false), format: .pem) {
                $0(password)
            })
        )
    }

    func testPrivateKey_whenInitDERFileWithPassword_shouldBeValid() async throws {
        // Given
        let resource = Certificates(.der).client()
        let password = Array(Data("password".utf8))

        // When
        let (session, _) = try await resolve(TestProperty {
            RequestDL.SecureConnection {
                RequestDL.PrivateKey(resource.privateKeyURL.absolutePath(percentEncoded: false), format: .der) {
                    $0(password)
                }
            }
        })

        // Then
        XCTAssertEqual(
            session.configuration.secureConnection?.privateKey,
            .privateKey(Internals.PrivateKey(
                resource.privateKeyURL.absolutePath(percentEncoded: false),
                format: .der,
                password: {
                    $0(password)
                }
            ))
        )
    }

    func testPrivateKey_whenInitPEMBytesNoPassword_shouldBeValid() async throws {
        // Given
        let resource = Certificates(.pem).client()
        let bytes = try Array(Data(contentsOf: resource.privateKeyURL))

        // When
        let (session, _) = try await resolve(TestProperty {
            RequestDL.SecureConnection {
                RequestDL.PrivateKey(bytes, format: .pem)
            }
        })

        // Then
        XCTAssertEqual(
            session.configuration.secureConnection?.privateKey,
            .privateKey(Internals.PrivateKey(bytes, format: .pem))
        )
    }

    func testPrivateKey_whenInitDERBytesNoPassword_shouldBeValid() async throws {
        // Given
        let resource = Certificates(.der).client()
        let bytes = try Array(Data(contentsOf: resource.privateKeyURL))

        // When
        let (session, _) = try await resolve(TestProperty {
            RequestDL.SecureConnection {
                RequestDL.PrivateKey(bytes, format: .der)
            }
        })

        // Then
        XCTAssertEqual(
            session.configuration.secureConnection?.privateKey,
            .privateKey(Internals.PrivateKey(
                bytes,
                format: .der
            ))
        )
    }

    func testPrivateKey_whenInitPEMBytesWithPassword_shouldBeValid() async throws {
        // Given
        let resource = Certificates(.pem).client(password: true)
        let bytes = try Array(Data(contentsOf: resource.privateKeyURL))
        let password = Array(Data("password".utf8))

        // When
        let (session, _) = try await resolve(TestProperty {
            RequestDL.SecureConnection {
                RequestDL.PrivateKey(bytes, format: .pem) {
                    $0(password)
                }
            }
        })

        // Then
        XCTAssertEqual(
            session.configuration.secureConnection?.privateKey,
            .privateKey(Internals.PrivateKey(bytes, format: .pem) {
                $0(password)
            })
        )
    }

    func testPrivateKey_whenInitDERBytesWithPassword_shouldBeValid() async throws {
        // Given
        let resource = Certificates(.der).client()
        let bytes = try Array(Data(contentsOf: resource.privateKeyURL))
        let password = Array(Data("password".utf8))

        // When
        let (session, _) = try await resolve(TestProperty {
            RequestDL.SecureConnection {
                RequestDL.PrivateKey(bytes, format: .der) {
                    $0(password)
                }
            }
        })

        // Then
        XCTAssertEqual(
            session.configuration.secureConnection?.privateKey,
            .privateKey(Internals.PrivateKey(
                bytes,
                format: .der,
                password: {
                    $0(password)
                }
            ))
        )
    }

    func testPrivateKey_whenInitPEMFileNoPasswordInBundle_shouldBeValid() async throws {
        // Given
        let resource = Certificates(.pem).client()

        let file = resource.privateKeyURL.lastPathComponent

        // When
        let (session, _) = try await resolve(TestProperty {
            RequestDL.SecureConnection {
                RequestDL.PrivateKey(file, in: .module, format: .pem)
            }
        })

        // Then
        XCTAssertEqual(
            session.configuration.secureConnection?.privateKey,
            Bundle.module.resolveURL(forResourceName: file).map {
                .file($0.absolutePath(percentEncoded: false))
            }
        )
    }

    func testPrivateKey_whenInitPEMFileWithPasswordInBundle_shouldBeValid() async throws {
        // Given
        let resource = Certificates(.pem).client(password: true)
        let password = Array(Data("password".utf8))

        let file = resource.privateKeyURL.lastPathComponent

        // When
        let (session, _) = try await resolve(TestProperty {
            RequestDL.SecureConnection {
                RequestDL.PrivateKey(file, in: .module, format: .pem) {
                    $0(password)
                }
            }
        })

        // Then
        XCTAssertEqual(
            session.configuration.secureConnection?.privateKey,
            Bundle.module.resolveURL(forResourceName: file).map {
                .privateKey(Internals.PrivateKey($0.absolutePath(percentEncoded: false), format: .pem) {
                    $0(password)
                })
            }
        )
    }

    func testCertificate_whenAccessBody_shouldBeNever() async throws {
        // Given
        let resource = Certificates(.pem).client()

        // Wehn
        let sut = RequestDL.PrivateKey(resource.privateKeyURL.absolutePath(percentEncoded: false))

        // Then
        try await assertNever(sut.body)
    }
}

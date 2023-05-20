/*
 See LICENSE for this package's licensing information.
*/

import Foundation

// swiftlint:disable file_length
/**
 A structure representing a form with headers.

 A `Form` object is used to encapsulate form data for HTTP requests. It allows you to specify the name,
 filename, content type, and data or URL associated with a form field. It also supports adding custom headers
 to the form.

 Usage:

 ```swift
 Form(
    name: "example",
    filename: "example.txt",
    contentType: .octetStream,
    data: someData
 )
 ```

 - Note: The `Headers` generic parameter represents the type of custom headers associated with the
 form. If no custom headers are needed, the default would be `EmptyProperty`.

 - SeeAlso: `Property`
 */
public struct Form<Headers: Property>: Property {

    // MARK: - Public properties

    /// Returns an exception since `Never` is a type that can never be constructed.
    public var body: Never {
        bodyException()
    }

    // MARK: - Internal properties

    let name: String
    let filename: String?
    let factory: PayloadFactory
    let headers: Headers

    // MARK: - Inits

    /**
     Creates a form with the given parameters.

     - Parameters:
        - name: The name of the form field.
        - filename: The filename associated with the form field, if applicable.
        - contentType: The content type of the form field.
        - data: The data associated with the form field.

     - Note: This initializer is available when `Headers` is `EmptyProperty`.
     */
    public init(
        name: String,
        filename: String? = nil,
        contentType: ContentType = .octetStream,
        data: Data
    ) where Headers == EmptyProperty {
        self.init(
            name: name,
            filename: filename,
            factory: DataPayloadFactory(
                data: data,
                contentType: contentType
            ),
            headers: EmptyProperty()
        )
    }

    /**
     Creates a form with the given parameters.

     - Parameters:
        - name: The name of the form field.
        - filename: The filename associated with the form field, if applicable.
        - contentType: The content type of the form field.
        - url: The URL associated with the form field.

     - Note: This initializer is available when `Headers` is `EmptyProperty`.
     */
    public init(
        name: String,
        filename: String? = nil,
        contentType: ContentType,
        url: URL
    ) where Headers == EmptyProperty {
        self.init(
            name: name,
            filename: filename ?? url.lastPathComponent,
            factory: FilePayloadFactory(
                url: url,
                contentType: contentType
            ),
            headers: EmptyProperty()
        )
    }

    /**
     Creates a form with the given parameters.

     - Parameters:
        - name: The name of the form field.
        - filename: The filename associated with the form field, if applicable.
        - contentType: The content type of the form field.
        - verbatim: The verbatim data associated with the form field.

     - Note: This initializer is available when `Headers` is `EmptyProperty` and `Verbatim`
     conforms to `StringProtocol`.
     */
    public init<Verbatim: StringProtocol>(
        name: String,
        filename: String? = nil,
        contentType: ContentType,
        verbatim: Verbatim
    ) where Headers == EmptyProperty {
        self.init(
            name: name,
            filename: filename,
            factory: StringPayloadFactory(
                verbatim: verbatim,
                contentType: contentType
            ),
            headers: EmptyProperty()
        )
    }

    /**
     Creates a form with the given parameters.

     - Parameters:
        - value: The value to be encoded and associated with the form field.
        - encoder: The JSON encoder to use for encoding the value. Default is `JSONEncoder()`.
        - name: The name of the form field.
        - filename: The filename associated with the form field, if applicable.
        - contentType: The content type of the form field.

     - Note: This initializer is available when `Headers` is `EmptyProperty` and `Value`
     conforms to `Encodable`.
     */
    public init<Value: Encodable>(
        _ value: Value,
        encoder: JSONEncoder = .init(),
        name: String,
        filename: String? = nil,
        contentType: ContentType = .json
    ) where Headers == EmptyProperty {
        self.init(
            name: name,
            filename: filename,
            factory: EncodablePayloadFactory(
                value,
                encoder: encoder,
                contentType: contentType
            ),
            headers: EmptyProperty()
        )
    }

    /**
     Creates a form with the given parameters.

     - Parameters:
        - json: The JSON object to be associated with the form field.
        - options: The JSON writing options to use for serializing the JSON object. Default is `[]`.
        - name: The name of the form field.
        - filename: The filename associated with the form field, if applicable.
        - contentType: The content type of the form field.

     - Note: This initializer is available when `Headers` is `EmptyProperty`.
     */
    public init(
        _ json: Any,
        options: JSONSerialization.WritingOptions = [],
        name: String,
        filename: String? = nil,
        contentType: ContentType = .json
    ) where Headers == EmptyProperty {
        self.init(
            name: name,
            filename: filename,
            factory: JSONPayloadFactory(
                jsonObject: json,
                options: options,
                contentType: contentType
            ),
            headers: EmptyProperty()
        )
    }

    /**
     Creates a form with the given parameters and custom headers.

     - Parameters:
        - name: The name of the form field.
        - filename: The filename associated with the form field, if applicable.
        - contentType: The content type of the form field.
        - data: The data associated with the form field.
        - headers: A closure that returns custom headers for the form.
     */
    public init(
        name: String,
        filename: String? = nil,
        contentType: ContentType = .octetStream,
        data: Data,
        @PropertyBuilder headers: () -> Headers
    ) {
        self.init(
            name: name,
            filename: filename,
            factory: DataPayloadFactory(
                data: data,
                contentType: contentType
            ),
            headers: headers()
        )
    }

    /**
     Creates a form with the given parameters and custom headers.

     - Parameters:
        - name: The name of the form field.
        - filename: The filename associated with the form field, if applicable.
        - contentType: The content type of the form field.
        - url: The URL associated with the form field.
        - headers: A closure that returns custom headers for the form.
     */
    public init(
        name: String,
        filename: String? = nil,
        contentType: ContentType,
        url: URL,
        @PropertyBuilder headers: () -> Headers
    ) {
        self.init(
            name: name,
            filename: filename ?? url.lastPathComponent,
            factory: FilePayloadFactory(
                url: url,
                contentType: contentType
            ),
            headers: headers()
        )
    }

    /**
     Creates a form with the given parameters and custom headers.

     - Parameters:
        - name: The name of the form field.
        - filename: The filename associated with the form field, if applicable.
        - contentType: The content type of the form field.
        - verbatim: The verbatim data associated with the form field.
        - headers: A closure that returns custom headers for the form.

     - Note: This initializer is available when `Verbatim` conforms to `StringProtocol`.
     */
    public init<Verbatim: StringProtocol>(
        name: String,
        filename: String? = nil,
        contentType: ContentType = .text,
        verbatim: Verbatim,
        @PropertyBuilder headers: () -> Headers
    ) {
        self.init(
            name: name,
            filename: filename,
            factory: StringPayloadFactory(
                verbatim: verbatim,
                contentType: contentType
            ),
            headers: headers()
        )
    }

    /**
     Creates a form with the given parameters and custom headers.

     - Parameters:
        - value: The value to be encoded and associated with the form field.
        - encoder: The JSON encoder to use for encoding the value. Default is `JSONEncoder()`.
        - name: The name of the form field.
        - filename: The filename associated with the form field, if applicable.
        - contentType: The content type of the form field.
        - headers: A closure that returns custom headers for the form.

     - Note: This initializer is available when `Value` conforms to `Encodable`.
     */
    public init<Value: Encodable>(
        _ value: Value,
        encoder: JSONEncoder = .init(),
        name: String,
        filename: String? = nil,
        contentType: ContentType = .json,
        @PropertyBuilder headers: () -> Headers
    ) {
        self.init(
            name: name,
            filename: filename,
            factory: EncodablePayloadFactory(
                value,
                encoder: encoder,
                contentType: contentType
            ),
            headers: headers()
        )
    }

    /**
     Creates a form with the given parameters and custom headers.

     - Parameters:
        - json: The JSON object to be associated with the form field.
        - options: The JSON writing options to use for serializing the JSON object. Default is `[]`.
        - name: The name of the form field.
        - filename: The filename associated with the form field, if applicable.
        - contentType: The content type of the form field.
        - headers: A closure that returns custom headers for the form.
     */
    public init(
        _ json: Any,
        options: JSONSerialization.WritingOptions,
        name: String,
        filename: String? = nil,
        contentType: ContentType = .json,
        @PropertyBuilder headers: () -> Headers
    ) {
        self.init(
            name: name,
            filename: filename,
            factory: JSONPayloadFactory(
                jsonObject: json,
                options: options,
                contentType: contentType
            ),
            headers: headers()
        )
    }

    private init(
        name: String,
        filename: String?,
        factory: PayloadFactory,
        headers: Headers
    ) {
        self.name = name
        self.filename = filename
        self.factory = factory
        self.headers = headers
    }

    // MARK: - Public static methods

    /// This method is used internally and should not be called directly.
    public static func _makeProperty(
        property: _GraphValue<Form<Headers>>,
        inputs: _PropertyInputs
    ) async throws -> _PropertyOutputs {
        property.assertPathway()

        let additionalHeaders = try await headers(
            property: property,
            inputs: inputs
        )

        return .leaf(FormNode(
            fragmentLength: inputs.environment.payloadPartLength,
            item: FormItem(
                name: property.name,
                filename: property.filename,
                additionalHeaders: additionalHeaders.isEmpty ? nil : additionalHeaders,
                charset: inputs.environment.charset,
                urlEncoder: inputs.environment.urlEncoder,
                factory: property.factory
            )
        ))
    }

    // MARK: - Private static methods

    private static func headers(
        property: _GraphValue<Form<Headers>>,
        inputs: _PropertyInputs
    ) async throws -> HTTPHeaders {
        let output = try await Headers._makeProperty(
            property: property.headers,
            inputs: inputs
        )

        return HTTPHeaders(
            output.node.search(for: RequestDL.Headers.Node.self)
                .lazy
                .filter { !$0.value.isEmpty }
                .map { ($0.key, $0.value) }
        )
    }
}
// swiftlint:enable file_length

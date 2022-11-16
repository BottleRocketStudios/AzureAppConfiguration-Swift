//
//  AzureAppConfiguration.swift
//  AzureAppConfiguration
//
//  Created by Russell Mirabelli
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//
import CryptoKit
import Foundation

public enum AzureAppConfiguration {

    /// Errors for preparing an Azure App Configuration request.
    /// Internal errors should never occur; please report them to the maintainer
    /// if they do.
    public enum PreparationError: Error {
        case internalError
        case urlCouldNotBePreparedFromEndpoint
        case secretCouldNotBeDecodedAsBase64
    }

    /// Prepares a URLRequest for use with Azure App Configuration. Handles all cryptographic signatures
    /// using CryptoKit (iOS required version 13.0).
    /// - Parameters:
    ///   - endpoint: The endpoint URL for your Azure App Configuration.
    ///   - secret: The secret for your Azure App Configuration
    ///   - credential: The ID or Credential for your Azure App Configuration
    /// - Throws: Errors thrown are `AzureAppConfigurationPreparationError`s.
    /// - Returns: A completed URLRequest
    public static func prepareRequest(endpoint: String, secret: String, credential: String) throws -> URLRequest {

        // Create a URL request
        let urlString = "\(endpoint)/kv?api-version=1"
        guard endpoint.starts(with: "https://"), let url = URL(string: urlString) else { throw PreparationError.urlCouldNotBePreparedFromEndpoint }
        var request = URLRequest(url: url)

        // Add the headers required by Azure App Configuration
        // Set the Date header to our Date as a UTC String.
        guard let dateString = ISO8601DateFormatter().string(for: Date()) else { throw PreparationError.internalError }
        request.addValue(dateString, forHTTPHeaderField: "Date")

        // Hash the request body (which is empty) using SHA256 and encode it as Base64
        let bodySHA256 = SHA256.hash(data: Data())
        let bodyBase64String = Data(bodySHA256).base64EncodedString()
        request.addValue(bodyBase64String, forHTTPHeaderField: "x-ms-content-sha256")

        // Remove the https, prefix to create a suitable "Host" value
        let hostString = endpoint.replacingOccurrences(of: "https://", with: "")

        // This gets the part of our URL that is after the endpoint, for example in https://myappconfig.azure.com/kv, it will get '/kv'
        let path = urlString.replacingOccurrences(of: endpoint, with: "")

        // Construct the string which we'll sign, using various previously created values.
        let stringToSign = "GET\n\(path)\n\(dateString);\(hostString);\(bodyBase64String)"
        guard let stringToSignData = stringToSign.data(using: .utf8) else { throw PreparationError.internalError }

        // Decode our access key from previously created variables, into bytes from base64.
        guard let decodedSecret = Data(base64Encoded: secret) else { throw PreparationError.secretCouldNotBeDecodedAsBase64 }

        // Sign our previously calculated string with HMAC 256 and our key. Convert it to Base64.
        var hmac = HMAC<SHA256>(key: SymmetricKey(data: decodedSecret))
        hmac.update(data: stringToSignData)
        let signature = Data(hmac.finalize()).base64EncodedString()

        // add signature to headers
        request.addValue("HMAC-SHA256 Credential=\(credential)&SignedHeaders=date;host;x-ms-content-sha256&Signature=\(signature)", forHTTPHeaderField: "Authorization")

        return request
    }

    /// Decodes the data from an Azure App Configuration response into a dictionary of
    /// key/value pairs (of strings) as sent by the service
    /// - Parameter data: The data returned from the Azure App Configuration service
    /// - Throws: Can throw errors from JSON decoding, but none of its own
    /// - Returns: A dictionary of key/value pairs
    public static func decodeResponse(data: Data) throws -> [String: String] {

        // A single key/value pair as provided by Azure App Configuration
        // swiftlint:disable nesting
        struct KVResponseElement: Codable {
            let key: String
            let value: String
        }

        // The overall response as provided by Azure App Configuration
        struct KVResponse: Codable {
            let items: [KVResponseElement]
        }
        // swiftlint:enable nesting

        // Decode the configuration into a response, then reduce the array into a dictionary
        let response = try JSONDecoder().decode(KVResponse.self, from: data)
        return response.items.reduce(into: [:], { partialResult, element in
            partialResult[element.key] = element.value
        })
    }

}

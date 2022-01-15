import XCTest
@testable import AzureAppConfiguration

class AzureAppConfigurationTests: XCTestCase {

    /// This is a complete example that demonstrates usage of the AzureAppConfiguration helpers;
    /// Fill out the endpoint, secret, and credential with values obtained when setting up an
    /// Azure App Configuration instance in the dashboard
    @available(macOS 12.0, *)

    /// This test verifies that if the endpoint provided is not an https URL, the
    /// preparation function will throw an error.
    func test_prepareRequestFailsWhenTheEndpointIsInvalid() throws {
        let endpoint = "http://foo"
        let secret = "Zm9v"
        let credential = "foo"
        XCTAssertThrowsError(try AzureAppConfiguration.prepareRequest(endpoint: endpoint, secret: secret, credential: credential), "should throw an error because the endpoint is not valid")
    }

    /// This test verifies that if the secret provided is not a base64 encoded string, the
    /// preparation function will throw an error.
    func test_prepareRequestFailsWhenTheSecretIsInvalid() throws {
        let endpoint = "https://azure.com"
        let secret = "foo"
        let credential = "foo"
        XCTAssertThrowsError(try AzureAppConfiguration.prepareRequest(endpoint: endpoint, secret: secret, credential: credential), "should throw an error because the secret is not valid")
    }

    /// This test verifies that a request will be prepared when the endpoint and secret are
    /// properly provided
    func test_prepareRequestSucceedsWhenParametersAreValid() throws {
        let endpoint = "https://azure.com"
        let secret = "Zm9v"
        let credential = "foo"
        let request = try AzureAppConfiguration.prepareRequest(endpoint: endpoint, secret: secret, credential: credential)
        XCTAssert(!request.debugDescription.isEmpty)
    }

    // Tests to write for decoding:

    func test_decodeResponseFailsWhenDataIsEmpty() throws {
        let data = Data()
        XCTAssertThrowsError(try AzureAppConfiguration.decodeResponse(data: data))
    }

    func test_decodeResponseFailsWhenDataIsNotJSON() throws {
        guard let data = "not a valid response".data(using: .utf8) else { XCTFail("Could not create data somehow"); return }
        XCTAssertThrowsError(try AzureAppConfiguration.decodeResponse(data: data))
    }

    func test_decodeSucceedsWithValidData() throws {
        let jsonString = """
        {
            "items": [
                {
                    "etag": "JPyzoVkUx8F4ighi4WDdmP9gFT5",
                    "key": "foo",
                    "label": null,
                    "content_type": "",
                    "value": "bar",
                    "tags": {},
                    "locked": false,
                    "last_modified": "2022-01-11T16:42:45+00:00"
                }
            ]
        }
        """
        guard let data = jsonString.data(using: .utf8) else { XCTFail("Could not create data somehow"); return }
        let dictionary = try AzureAppConfiguration.decodeResponse(data: data)
        XCTAssertNotNil(dictionary["foo"], "Dictionary should contain an entry for 'foo'")
    }

}

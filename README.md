# ``AzureAppConfiguration``

The AzureAppConfiguration package allows for simple construction of
a `URLRequest` for Azure's App Configuration Service, and decoding
the response from this service into a dictionary.

A discussion of what Azure App Configuration can be found [here](https://docs.microsoft.com/en-us/azure/azure-app-configuration/overview).

## Overview

The AzureAppConfiguration structure contains a pair of static helper
functions; no instantiation of an AzureAppConfiguration structure is
needed or helpful.

Typically, you'd use this function one time at the start of your application,
or whenever you want to check if the configuration has changed post-launch.

A very simple example can be found in the unit tests, and is also below:

```
let endpoint = "https://OBTAINED-FROM-DASHBOARD.azconfig.io"
let secret = "PASTE-SECRET-HERE"
let credential = "PASTE-CREDENTIAL-HERE"

// Fetch and decode the configuration
let request = try AzureAppConfiguration.prepareRequest(endpoint: endpoint, secret: secret, credential: credential)
let (data, _) = try await URLSession.shared.data(for: request)
let dictionary = try AzureAppConfiguration.decodeResponse(data: data)
```

## Topics

### Preparing a request

The primary reason this package exists is that while preparing these requests is not
terribly complex, it does require some precision in setup. In order to speed up this
preparation, the `AzureAppConfiguration.prepareRequest()` method ensures that all 
headers are set properly.

You'll need to provide the endpoint, secret, and credential as obtained from the
Azure App Configuration dashboard. See documentation on setting up this service here:
*** WRITE MEDIUM ARTICLE AND PASTE URL HERE ***

### Decoding the response

The response comes in a very simple format, but decoding it to a dictionary does take
a one-line `reduce` method on the response data. In order to simplify this as well,
this can be handled in `AzureAppConfiguration.decodeResponse()`

### Errors Thrown

In order to best support async/await, these methods will throw an error if any are
found. Errors can occur because the `endpoint` or `secret` are not provided in a
correct format.

When decoding, typical JSON decoding errors may be thrown.

### See also

[OVERVIEW](https://docs.microsoft.com/en-us/azure/azure-app-configuration/overview)

## Example

See the overall sample from within the unit tests, or as above.

## Requirements

Requires iOS 13.0, tvOS 13.0, macOS 10.15


## Installation

Add this to your project using Swift Package Manager. In Xcode that is simply: File > Swift Packages > Add Package Dependency... and you're done.


## Author

[Bottle Rocket Studios](https://www.bottlerocketstudios.com/)


## License

AzureAppConfiguration is available under the Apache 2.0 license. See [the LICENSE file](LICENSE) for more information.


## Contributing

See the [CONTRIBUTING] document. Thank you, [contributors]!

[CONTRIBUTING]: CONTRIBUTING.md
[contributors]: https://github.com/BottleRocketStudios/AzureAppConfiguration-Swift/graphs/contributors

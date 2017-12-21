![Openpay iOS](http://www.openpay.mx/img/github/ios.jpg)

iOS swift library for tokenizing credit/debit card and collect device information

Current version: v2.0.0

Looking for Objective-C Version? Checkout: (https://github.com/open-pay/openpay-ios)

Please refer to the following documentation sections for field documentation:
* [Create a Token](http://www.openpay.mx/docs/api/#crear-un-nuevo-token)
* [Fraud Tool](http://www.openpay.mx/docs/fraud-tool.html)

## Requirements

- iOS SDK 10.3+
- ARC
- WebKit.framework

## Installation

- Download the latest released version (SDK-v2.0.0.zip).
- Add openpay framework (openpay-v2.0.0.framework) to General -> Linked Framework and Libraries.
- Add openpay framework (openpay-v2.0.0.framework) to General -> Embeded Binaries.
- Add webkit framework to Build Phases -> Link Binary With Libraries.

## Usage

```swift
import Openpay
```

#### Create a instance object

For create an instance Openpay needs:
- MerchantId
- Public API Key

```swift
let openpay = Openpay(withMerchantId: "Your Merchant ID",
							   andApiKey: "Your Private Key",
						isProductionMode: false,
						         isDebug: false)
```

#### Production Mode

Use isProductionMode = true

```swift
let openpay = Openpay(withMerchantId: "Your Merchant ID",
							   andApiKey: "Your Private Key",
						isProductionMode: true,
						         isDebug: false)
```

#### Create a SessionID

The framework contains a function for generate a device sessionID.
The following parameters are required:
-Function to call when SessionID is generated
-Function to call when error occurs

```swift
let openpay = Openpay(withMerchantId: "Your Merchant ID",
							   andApiKey: "Your Private Key",
						isProductionMode: true,
						         isDebug: false)

openpay.createDeviceSessionId(successFunction: successSessionID,
							  failureFunction: failSessionID)
```

#### Display Card Form

The framework contains a form for the user directly capture his card's minimum required data.
For display the form you need to pass the following parameters:
-Current UIViewController
-Function to call when capture ends
-Function to call when error occurs
-The title to display at the top of form

```swift
openpay.loadCardForm(in: self,
		successFunction: successCard,
		failureFunction: failCard,
			  formTitle: "Openpay")
```

#### Create a token

For more information about how to create a token, please refer to [Create a token] (http://www.openpay.mx/docs/api/#crear-un-nuevo-token)

##### With only required fields captured by the user

```swift
let openpay = Openpay(withMerchantId: "Your Merchant ID",
							   andApiKey: "Your Private Key",
						isProductionMode: true,
						         isDebug: false)

openpay.loadCardForm(in: self,
		successFunction: successCard,
		failureFunction: failCard,
			  formTitle: "Openpay")

openpay.createTokenWithCard(address: nil,
					successFunction: successToken,
					failureFunction: failToken)

```

##### Response

If the request is correct, return an instance of OPToken.

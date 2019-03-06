![Openpay iOS](http://www.openpay.mx/img/github/ios.jpg)

iOS swift library for tokenizing credit/debit card and collect device information

Current version: v2.0.2

Looking for Objective-C Version? Checkout: (https://github.com/open-pay/openpay-ios)

Please refer to the following documentation sections for field documentation:
* [Create a Token](http://www.openpay.mx/docs/api/#crear-un-nuevo-token)
* [Fraud Tool](http://www.openpay.mx/docs/fraud-tool.html)

## Requirements

- iOS SDK 10.3+
- ARC
- WebKit.framework

## Installation

- Download the latest released version (https://github.com/open-pay/openpay-swift-ios/releases/download/v.2.0.2/SDK-v2.0.2.zip).
- Add openpay framework (Openpay.framework)
	- Go to General -> Embedded Binaries
	- Click "Add items"
	- In the popup, click "Add Other..." option
	- Select the file "Openpay.framework" and click "Open"
	- Check the option "Copy items if needed" and click "Finish"
- Add webkit framework
	- Go to General -> Linked Framework and Libraries
	- Click "Add items"
	- Search for "WebKit.framework", select it and click "Add"

## Usage

```swift
import Openpay
```

#### Create a instance object

For create an instance Openpay needs:
- MerchantId
- Public API Key

```swift
static let MERCHANT_ID = "merchantId"
static let API_KEY = "apiKey"

var openpay : Openpay!

func myFunction() {
	openpay = Openpay(withMerchantId: MERCHANT_ID, andApiKey: API_KEY, isProductionMode: false, isDebug: false)
}
```

#### Production Mode

Use isProductionMode = true

```swift
var openpay : Openpay!

func myFunction() {
	openpay = Openpay(withMerchantId: MERCHANT_ID, andApiKey: API_KEY, isProductionMode: true, isDebug: false)
}
```

#### Create a SessionID

The framework contains a function for generate a device sessionID.
The following parameters are required:
-Function to call when SessionID is generated
-Function to call when error occurs

```swift
var openpay : Openpay!

func myFunction() {
        openpay = Openpay(withMerchantId: MERCHANT_ID, andApiKey: API_KEY, isProductionMode: false, isDebug: false)
        openpay.createDeviceSessionId(successFunction: successSessionID, failureFunction: failSessionID)
}

func successSessionID(sessionID: String) {
        print("SessionID: \(sessionID)")
}

func failSessionID(error: NSError) {
        print("\(error.code) - \(error.localizedDescription)")
}
```

#### Display Card Form

The framework contains a form for the user directly capture his card's minimum required data.
For display the form you need to pass the following parameters:
-Current UIViewController
-Function to call when capture ends
-Function to call when error occurs
-The title to display at the top of form

```swift
var openpay : Openpay!

func myFunction() {
        openpay = Openpay(withMerchantId: MERCHANT_ID, andApiKey: API_KEY, isProductionMode: false, isDebug: false)
        openpay.loadCardForm(in: self, successFunction: successCard, failureFunction: failCard, formTitle: "Openpay")
}

func successCard() {

}

func failCard(error: NSError) {
	print("\(error.code) - \(error.localizedDescription)")
}
```

#### Create a token

For more information about how to create a token, please refer to [Create a token] (http://www.openpay.mx/docs/api/#crear-un-nuevo-token)

##### With only required fields captured by the user

```swift
var openpay : Openpay!

func myFunction() {
        openpay = Openpay(withMerchantId: MERCHANT_ID, andApiKey: API_KEY, isProductionMode: false, isDebug: false)
        openpay.loadCardForm(in: self, successFunction: successCard, failureFunction: failCard, formTitle: "Openpay")
}

func successCard() {
	openpay.createTokenWithCard(address: nil, successFunction: successToken, failureFunction: failToken)
}

func failCard(error: NSError) {
	print("\(error.code) - \(error.localizedDescription)")
}

func successToken(token: OPToken) {
        print("TokenID: \(token.id)")
}

func failToken(error: NSError) {
        print("\(error.code) - \(error.localizedDescription)")
}
```

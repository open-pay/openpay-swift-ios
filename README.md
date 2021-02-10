
![Openpay iOS](http://www.openpay.mx/img/github/ios.jpg)


iOS swift library for tokenizing credit/debit card and collect device information
Current version: v3.0.0


Please refer to the following documentation sections for field documentation:
* [Create a Token](http://www.openpay.mx/docs/api/#crear-un-nuevo-token)
* [Fraud Tool](http://www.openpay.mx/docs/fraud-tool.html)

## Requirements

- iOS SDK 14.3+

## Installation

- Download the latest released version (https://github.com/open-pay/openpay-swift-ios/releases/download/v3.0.0/OpenpayKit.framework.zip).
- Add openpay framework (Openpay.framework)
  - Drag & drop the framework library to your workspace
  - Go to General -> Frameworks, Libraries, and Embedded Content and verify that the framework was added. Also set Embed & Sign 
	to the Embed option.


## Usage

```swift
import OpenpayKit
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

##### With custom form

```
 let card = TokenizeCardRequest(cardNumber: cardNumber,holderName:holderName, expirationYear: expirationYear, expirationMonth: expirationMonth, cvv2: cvv2)
        
// request token by card model
openpay.tokenizeCard(card: card) { (OPToken) in
    print(OPToken.id)            
} failureFunction: { (NSError) in
    print(NSError)
}
```


## Remove Unused Architectures

The universal framework will run on both simulators and devices. But there is a problem, Apple doesn’t allow to upload the application with unused architectures to the App Store.

Please make sure that you have "Remove Unused Architectures Script" added in your project.

- Select the Project -> Choose Target -> Project Name -> Select Build Phases -> Press "+" -> New Run Script Phase -> Name the script as "Remove Unused Architectures Script".

Be sure that this Build Phase is the last one

```
APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"
# This script loops through the frameworks embedded in the application and 
# removes unused architectures.
find "$APP_PATH" -name '*.framework' -type d | while read -r FRAMEWORK
do
FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable)
FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"
echo "Executable is $FRAMEWORK_EXECUTABLE_PATH"
EXTRACTED_ARCHS=()
for ARCH in $ARCHS
do
echo "Extracting $ARCH from $FRAMEWORK_EXECUTABLE_NAME"
lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
done
echo "Merging extracted architectures: ${ARCHS}"
lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}"
rm "${EXTRACTED_ARCHS[@]}"
echo "Replacing original executable with thinned version"
rm "$FRAMEWORK_EXECUTABLE_PATH"
mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$FRAMEWORK_EXECUTABLE_PATH"
done

```

Thats all !. 

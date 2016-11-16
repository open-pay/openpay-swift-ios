![Openpay iOS](http://www.openpay.mx/img/github/ios.jpg)

iOS Swift library for tokenizing credit/debit card and collect device information

Current version : 1.1

Looking for Objective-C Version? Checkout: (https://github.com/open-pay/openpay-ios)

Please refer to the following documentation sections for field documentation:
* [Create a Token](http://www.openpay.mx/docs/api/#crear-un-nuevo-token)
* [Fraud Tool](http://www.openpay.mx/docs/fraud-tool.html)

## Requirements

- ARC
- CoreLocation.framework

## Installation

- [Download the pre-built framework](https://github.com/open-pay/openpay-ios/releases).
- Add Openpay to your project -> Link Binary With Libraries and Link Framework.
- Add CoreLocation.framework to Build Phases -> Link Binary With Libraries.

### Location Permissions

For location collection support you'll need to add this key to your
**Info.plist** file:

``` 
<key>NSLocationWhenInUseUsageDescription</key>
<string></string>
```

If you choose `KLocationCollectorConfigRequestPermission` the collector
will request permission for you if needed. If you choose
`KLocationCollectorConfigPassive` the collector will only gather
location information if your app has requested permission and the user has granted it permission.

#### Headers

##### includes folder
The includes folder is automatically included in the project's header search path.

- Copy the include folder to your project (or include/*.h to your existing include folder). Drag the folder to your project to add the references.

If you copy the files to a location other than includes you'll probably need to add the path to User Header Search Paths in your project settings.

##### Direct copy
You can copy the headers directly into your project and add them as direct references.
- Drag the contents of 'include' folder to your project (select copy if needed)

## Usage

```swift
import Openpay
```

#### Create a instance object

For create an instance Openpay needs:
- MerchantId
- Public API Key

```swift
Openpay openpay = Openpay(withMerchantId: MainViewController.MERCHANT_ID, 
							   andApiKey: MainViewController.API_KEY, 
						isProductionMode: false, 
						         isDebug: false)
```

#### Production Mode

Use isProductionMode = true

```swift
Openpay openpay = Openpay(withMerchantId: MainViewController.MERCHANT_ID, 
							   andApiKey: MainViewController.API_KEY, 
						isProductionMode: true, 
						         isDebug: false)
```

#### Create a SessionID

The framework contains a function for generate a device sessionID. 
The following parameters are required:
-Function to call when SessionID is generated
-Function to call when error occurs

```swift
Openpay openpay = Openpay(withMerchantId: MainViewController.MERCHANT_ID, 
							   andApiKey: MainViewController.API_KEY, 
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
Openpay openpay = Openpay(withMerchantId: MainViewController.MERCHANT_ID, 
							   andApiKey: MainViewController.API_KEY, 
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


## Contributing


#### Tests

Please include tests with all new code. Also, all existing tests must pass before new code can be merged.

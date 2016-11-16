//
//  Openpay.swift
//  Openpay
//
//  Created by Israel Grijalva Correa on 9/27/16.
//  Copyright © 2016 Openpay. All rights reserved.
//

import Foundation
import UIKit

public class Openpay {

    private static let API_URL_SANDBOX = "https://sandbox-api.openpay.mx"
    private static let API_URL_PRODUCTION = "https://api.openpay.mx"
    private static let API_VERSION = "1.1"
    private static let OP_MODULE_TOKENS = "tokens"
    private static let OP_HTTP_METHOD_POST = "POST"
    private static let OP_HTTP_METHOD_GET = "GET"
    private static let OPENPAY_IOS_VERSION = "1.0.1"
    private static let DC_MERCHANT_ID = 203000
    private static let OpenpayDomain = "com.openpay.ios.lib"
    private static let OPErrorMessageKey = "com.openpay.ios.lib:ErrorMessageKey"
    private static let OPAPIError = 9999;
    
    
    private var merchantId: String!
    private var apiKey: String!
    private var sessionID: String!
    private var isProductionMode: Bool!
    private var connection: NSURLConnection!
    private var request: NSMutableURLRequest!
    private var queue: OperationQueue!
    private var isDebug: Bool!
    private var hostViewController: UIViewController!
    private weak var activeField: UITextField?
    
    private var cardView: UIView!
    private var processCard: OPCard!
    private var scrollView: UIScrollView!
    private var inview: UIView!
    
    private var successCard: (() -> Void)!
    private var failureCard: ((_ error: NSError) -> Void)!
    
    private var pickerControl: PickerControl!
    
    private var holderValid: Bool = false
    
    private enum indexTag: Int {
        case holder = 1
        case card = 2
        case picker = 3
        case cvv = 4
        case date = 7
        case navBar = 99
        case scroll = 98
        case inview = 97
        case pickerBar = 95
        case pickerView = 94
        case pickerDone = 93
    }
    
    public init(withMerchantId merchantId: String, andApiKey apiKey: String, isProductionMode: Bool ) {
        self.initialize(with: merchantId, apiKey: apiKey, isProductionMode: isProductionMode, isDebug: false )
    }
    
    
    public init(withMerchantId merchantId: String, andApiKey apiKey: String, isProductionMode: Bool, isDebug: Bool ) {
        self.initialize(with: merchantId, apiKey: apiKey, isProductionMode: isProductionMode, isDebug: isDebug )
    }
    
    
    private func initialize(with merchantId: String, apiKey: String, isProductionMode: Bool, isDebug: Bool ) {
        self.merchantId = merchantId
        self.apiKey = apiKey
        self.isProductionMode = isProductionMode
        self.request = nil
        self.connection = nil
        self.queue = OperationQueue()
        self.isDebug = isDebug
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        KDataCollector.shared().debug = self.isDebug
        KDataCollector.shared().merchantID = Openpay.DC_MERCHANT_ID
        KDataCollector.shared().locationCollectorConfig = KLocationCollectorConfig.requestPermission
        KDataCollector.shared().environment = isProductionMode == true ? KEnvironment.production : KEnvironment.test
        if (self.isDebug == true) {
            print( " \(KDataCollector.shared().merchantID)" )
            switch KDataCollector.shared().environment {
            case KEnvironment.test:
                print( "KEnvironment: Test" )
            case KEnvironment.production:
                print( "KEnvironment: Production" )
            default:
                print( "KEnvironment: Unknown" )
            }
        }
        
        print("Created DeviceCollector")
    }

    public func createTokenWithCard(address: OPAddress!, successFunction: @escaping (_ responseParams: OPToken) -> Void, failureFunction: @escaping (_ error: NSError) -> Void ) {
        if address != nil { processCard.address = address }
        if (processCard.valid) {
            sendFunction(method: Openpay.OP_MODULE_TOKENS, data: processCard.asDictionary(), httpMethod: Openpay.OP_HTTP_METHOD_POST, successFunction: successFunction, failureFunction: failureFunction)
        } else {
            let cardErrors: Dictionary<String, Any> = [
                "errors":processCard.errors
            ]
            let error: NSError = NSError(domain: Openpay.OpenpayDomain, code: 1001, userInfo: cardErrors)
            failureFunction(error)
        }
    }
    
    public func getTokenWithId(tokenId: String,
                        successFunction: @escaping (_ responseParams: OPToken) -> Void,
                        failureFunction: @escaping (_ error: NSError) -> Void ) {
        
        sendFunction(method: String(format: "%@/%@",Openpay.OP_MODULE_TOKENS,tokenId), data: nil, httpMethod: Openpay.OP_HTTP_METHOD_GET, successFunction: successFunction, failureFunction: failureFunction)

    }
    
    public func createDeviceSessionId(successFunction: @escaping (_ sessionId: String) -> Void,
                                      failureFunction: @escaping (_ error: NSError) -> Void) {
        sessionID = UUID().uuidString
        sessionID = sessionID.replacingOccurrences(of: "-", with: "")

        //Call device collector
        KDataCollector.shared().collect(forSession: sessionID) { (sessionID, success, error) in
            if success {
                successFunction(sessionID)
                if ( self.isDebug == true ) {
                    print( "SessionID: \(sessionID)" )
                }
                
            } else {
                if ((error) != nil ) {
                    print( error!.localizedDescription )
                }
                let userInfoDict: Dictionary<String, Any> = ["errors": NSLocalizedString("error.json", bundle: Bundle(for: Openpay.self), comment: "Error JSON")]
                let OPError = NSError(domain: Openpay.OpenpayDomain, code: Openpay.OPAPIError, userInfo: userInfoDict)
                failureFunction(OPError)
            }
        }
        
    }
    
    
    
    
    private func sendFunction( method: String,
                       data: Dictionary<String, Any>!,
                       httpMethod: String,
                       successFunction: @escaping (_ responseParams: OPToken) -> Void,
                       failureFunction: @escaping (_ error: NSError) -> Void) {
        
        var operationError: NSError!
        let urlPath: String = String(format: "%@/v1/%@/%@", ( isProductionMode == true ? Openpay.API_URL_PRODUCTION : Openpay.API_URL_SANDBOX ), self.merchantId, method)
        let url: URL = URL(string: urlPath)!
        let request = NSMutableURLRequest()
        request.url = url
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        request.setValue(String(format: "application/json;revision=%@",Openpay.API_VERSION), forHTTPHeaderField:"Accept")
        request.setValue(String(format: "OpenPay-iOS/%@", Openpay.OPENPAY_IOS_VERSION), forHTTPHeaderField:"User-Agent")
        
        
        let authStr: String = String(format: "%@:%@", self.apiKey, "")
        let authData: Data =  authStr.data(using: String.Encoding.ascii)!
        let authValue: String = authData.base64EncodedString(options: Data.Base64EncodingOptions.endLineWithCarriageReturn )
        
        request.setValue( String(format: "Basic %@",authValue), forHTTPHeaderField: "Authorization")
        
        do {
            if (data != nil) {
                let payloadData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                request.httpBody = payloadData
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            failureFunction(error)
            return
        }
        
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, errorUrl in
            
            if (self.isDebug==true) {  print( String(format: "%@ %@", NSLocalizedString("debug.request", bundle: Bundle(for: Openpay.self), comment: "Debug Request"), "\(url)") ) }
            
            if errorUrl != nil {
                if let httpResponse = response as? HTTPURLResponse {
                    print("error \(httpResponse.statusCode)")
                }
                if (self.isDebug==true) { print( String(format: "%@ %@", NSLocalizedString("error.request", bundle: Bundle(for: Openpay.self), comment: "Error JSON"), "\(errorUrl)") ) }
                operationError = errorUrl as NSError!
                failureFunction(operationError)
                return
            } else {
                
            }
            
            let jsonDictionary: Dictionary<String, Any> = self.dictionaryFromJSONData(data: data!, outError: &operationError)
            if jsonDictionary["id"] != nil {
                if (self.isDebug==true) {  print(NSLocalizedString("debug.responseok", bundle: Bundle(for: Openpay.self), comment: "Debug Response OK")) }
                successFunction( OPToken.init(with: jsonDictionary) )
            } else {
                let userInfoDict: Dictionary<String, Any> = ["errors": NSLocalizedString("error.json", bundle: Bundle(for: Openpay.self), comment: "Error JSON")] // "The response from Openpay failed to get parsed into valid JSON."]
                operationError = NSError(domain: Openpay.OpenpayDomain, code: Openpay.OPAPIError, userInfo: userInfoDict)
                print("Parsing Response Error: \(operationError.code): \(operationError.localizedDescription)")
                failureFunction(operationError!)
            }
            

        }
        
        task.resume()

    }
    
    
    
    
    
    
    private func dictionaryFromJSONData(data: Data, outError: inout NSError!) -> Dictionary<String, Any>! {
        var jsonDictionary: Dictionary<String, Any>!
        do {
            jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            if (jsonDictionary == nil) {
                if (outError==nil) {
                    let userInfoDict: Dictionary<String, Any> = ["errors": NSLocalizedString("error.json", bundle: Bundle(for: Openpay.self), comment: "Error JSON")]
                    outError = NSError(domain: Openpay.OpenpayDomain, code: Openpay.OPAPIError, userInfo: userInfoDict)
                    print("dictionaryFromJSONData Error: \(outError)")
                }
                return nil;
            }
        } catch {
            print("dictionaryFromJSONData Error: \(outError)")
        }

        return jsonDictionary;
    }

    
    
    
    public func loadCardForm(in viewController: UIViewController,
                                successFunction: @escaping () -> Void,
                                failureFunction: @escaping (_ error: NSError) -> Void,
                                formTitle: String
                            ) {
        print("Display CardForm")
        processCard = OPCard()
        self.hostViewController = viewController
        cardView = CardView.instanceFromNib()
        cardView.translatesAutoresizingMaskIntoConstraints = (false)
        self.hostViewController.view.addSubview(cardView)
        self.hostViewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view":cardView]))
        self.hostViewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view":cardView]))
        
        self.successCard = successFunction
        self.failureCard = failureFunction
        
        let touch = UITapGestureRecognizer(target:self, action: #selector(touchView) )
        cardView.addGestureRecognizer(touch)
        
        if let navigationBar = self.hostViewController.view.viewWithTag(indexTag.navBar.rawValue) as? UINavigationBar {
            navigationBar.topItem?.title = formTitle
            navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("button.cancel", bundle: Bundle(for: Openpay.self), comment: "Cancel"), style: .plain, target: self, action: #selector(Openpay.cancelAction))
            navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("button.continue", bundle: Bundle(for: Openpay.self), comment: "Continue"), style: .done, target: self, action: #selector(Openpay.continueProcess))
            navigationBar.topItem?.rightBarButtonItem?.isEnabled = false
        }
        
        if let holderField = self.hostViewController.view.viewWithTag(indexTag.holder.rawValue) as? SecureUITextField {
            holderField.addTarget(self, action: #selector( Openpay.holderChange(textField:) ), for: UIControlEvents.editingChanged)
            holderField.addTarget(self, action: #selector( Openpay.textFieldDidBeginEditing(textField:) ), for: UIControlEvents.editingDidBegin)
            holderField.addTarget(self, action: #selector( Openpay.textFieldDidBeginEditing(textField:) ), for: UIControlEvents.editingDidEnd)
            holderField.delegate = holderField
        }
        
        if let cardNumberField = self.hostViewController.view.viewWithTag(indexTag.card.rawValue) as? SecureUITextField {
            cardNumberField.addTarget(self, action: #selector( Openpay.cardNumberChange(textField:) ), for: UIControlEvents.editingChanged)
            cardNumberField.addTarget(self, action: #selector( Openpay.textFieldDidBeginEditing(textField:) ), for: UIControlEvents.editingDidBegin)
            cardNumberField.addTarget(self, action: #selector( Openpay.textFieldDidBeginEditing(textField:) ), for: UIControlEvents.editingDidEnd)
        }
        
        if let cvvField = self.hostViewController.view.viewWithTag(indexTag.cvv.rawValue) as? SecureUITextField {
            cvvField.addTarget(self, action: #selector( Openpay.cvvChange(textField:) ), for: UIControlEvents.editingChanged)
            cvvField.addTarget(self, action: #selector( Openpay.textFieldDidBeginEditing(textField:) ), for: UIControlEvents.editingDidBegin)
            cvvField.addTarget(self, action: #selector( Openpay.textFieldDidBeginEditing(textField:) ), for: UIControlEvents.editingDidEnd)
        }
        
        if let dateField = self.hostViewController.view.viewWithTag(indexTag.date.rawValue) as? UIButton {
            dateField.addTarget(self, action: #selector( Openpay.showDatePicker ), for: UIControlEvents.touchDown)
        }
        
        if let picker = self.hostViewController.view.viewWithTag(indexTag.picker.rawValue) as? UIPickerView {
            pickerControl = PickerControl()
            var monthNames = NSLocalizedString("month.names", bundle: Bundle(for: Openpay.self), comment: "Month names")
            pickerControl.generateDates(monthLocalized: monthNames)
            picker.dataSource = pickerControl
            picker.delegate = pickerControl
        }
        
        if let pickerBar = self.hostViewController.view.viewWithTag(indexTag.pickerBar.rawValue) as? UIToolbar {
            pickerBar.items?[1] = UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector( Openpay.finishPick ))
        }
        
        if let scrollView = self.hostViewController.view.viewWithTag(indexTag.scroll.rawValue) as? UIScrollView {
            self.scrollView = scrollView
        }
        
        if let inView = self.hostViewController.view.viewWithTag(indexTag.inview.rawValue) as? CardView {
            self.inview = inView
        }
        
        let contentInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        

    }
    
    
    @objc private func continueAction(sender: UIButton!) {
        continueProcess()
    }
    
    @objc private func continueProcess() {
        self.successCard()
        cardView.removeFromSuperview()
    }
    
    private func textFieldShouldReturn(textField: UITextField) {
        let nextTage=textField.tag+1;
        if nextTage == indexTag.picker.rawValue {
            showDatePicker()
        }else {
            let nextResponder=self.hostViewController.view.viewWithTag(nextTage) as UIResponder!
            if (nextResponder != nil){
                nextResponder?.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        }
    }
    
    
    private func parseInt(string: String!) -> Int {
        var value: Int = 0
        if let intVal = Int(string) {
            value = intVal
        }
        return value
    }
    
    @objc private func cancelAction() {
        cardView.removeFromSuperview()
    }
    
    private func validateCharacters(textFieldToChange: UITextField) {
        for chr in (textFieldToChange.text?.characters)! {
            if (!(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") && !(chr >= " " && chr <= " ") ) {
                textFieldToChange.deleteBackward()
            }
        }
    }
    
    @objc private func touchView() {
        cardView.endEditing(true)
        if let pickerView = self.hostViewController.view.viewWithTag(indexTag.pickerView.rawValue) {
            if pickerView.isHidden == false { finishPick() }
        }
    }
    
    @objc private func textFieldDidEndEditing(textField: UITextField) {
        self.activeField = nil
    }
    
    @objc private func textFieldDidBeginEditing(textField: UITextField) {
        self.activeField = textField
    }
    
    @objc private func keyboardDidShow(notification: NSNotification) {
        if let activeField = self.activeField, let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if let pickerView = self.hostViewController.view.viewWithTag(indexTag.pickerView.rawValue) {
                if pickerView.isHidden == false { finishPick() }
            }
            
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            var aRect = cardView.frame
            aRect.size.height -= keyboardSize.size.height
            if (!aRect.contains(activeField.frame.origin)) {
                scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    @objc private func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func showDatePicker() {
        cardView.endEditing(true)
        if let pickerView = self.hostViewController.view.viewWithTag(indexTag.pickerView.rawValue) {
            pickerView.isHidden = false
            
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: pickerView.bounds.height, right: 0.0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            var aRect = cardView.frame
            aRect.size.height -= pickerView.bounds.size.height
            if let dateField = self.hostViewController.view.viewWithTag(indexTag.date.rawValue) as? UIButton {
                if (!aRect.contains(dateField.frame.origin)) {
                    scrollView.scrollRectToVisible(dateField.frame, animated: true)
                }
            }
            
            
            
        }
    }
    
    private func formatCardNumber(cardNumber: String, type: OPCard.OPCardType) -> String {
        let cleanNumber: String = cardNumber.replacingOccurrences(of: " ", with: "")
        //let cleanNumber: String = cardNumber.trimmingCharacters(in: .whitespaces)
        let separator: Character = " "
        var segments: [Int] = [0]
        var outNumber: String = ""
        
        switch type {
        case OPCard.OPCardType.OPCardTypeVisa:
            segments = [4,8,12,16]
        case OPCard.OPCardType.OPCardTypeMastercard:
            segments = [4,8,12,16]
        case OPCard.OPCardType.OPCardTypeAmericanExpress:
            segments = [4,10,15]
        case OPCard.OPCardType.OPCardTypeUnknown:
            segments = [4,8,12,16]
        default:
            segments = [0]
        }
        
        var ci: Int = 0;
        var cp: Int = 0;
        for i in cleanNumber.characters {
            if( segments[0] != 0 && cp == segments[ci] ) {
                outNumber.characters.append(separator)
                if(segments.count > 1) {
                    if(ci < segments.count) {
                        ci += 1
                    }else{
                        ci = 0
                    }
                }
            }
            outNumber.characters.append(i)
            cp += 1
        }
        
        return outNumber
    }
    
    // DATA VALIDATORS **********************************************************************
    
    @objc private func holderChange(textField: UITextField) {
        let max = 30
        let min = 5
        validateCharacters(textFieldToChange: textField)
        processCard.holderName = textField.text!
        holderValid = ((textField.text?.characters.count)! > min && (textField.text?.characters.count)! <= max)
        textField.textColor = holderValid ? UIColor.black : UIColor.red
        if textField.text?.characters.count == max && holderValid {
            textFieldShouldReturn(textField: textField)
        } else if (textField.text?.characters.count)! > max {
            textField.deleteBackward()
        }
        checkButtonCard()
    }
    
    @objc private func cardNumberChange(textField: UITextField) {
        let max = 19
        processCard.number = textField.text!
        if processCard.numberValid {
            textFieldShouldReturn(textField: textField)
        }
        if (textField.text?.characters.count)! > max {
            textField.deleteBackward()
        }
        let formattedNumber = formatCardNumber(cardNumber: textField.text!, type: processCard.type)
        textField.text! = formattedNumber
        checkButtonCard()
    }
    
    @objc private func cvvChange(textField: UITextField) {
        let max = 41
        processCard.cvv2 = textField.text!
        var cvvValid = processCard.securityCodeCheck == OPCard.OPCardSecurityCodeCheck.OPCardSecurityCodeCheckPassed
        if cvvValid {
            textField.superview?.endEditing(true)
        }
        if (textField.text?.characters.count)! > max {
            textField.deleteBackward()
        }
        checkButtonCard()
    }
    
    @objc private func finishPick() {
        if let pickerView = self.hostViewController.view.viewWithTag(indexTag.pickerView.rawValue) {
            pickerView.isHidden = true
            let contentInsets = UIEdgeInsets.zero
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        }
        if let dateField = self.hostViewController.view.viewWithTag(indexTag.date.rawValue) as? UIButton {
            if let picker = self.hostViewController.view.viewWithTag(indexTag.picker.rawValue) as? UIPickerView {
                var month: PickerItem = pickerControl.pickerItems[0][picker.selectedRow(inComponent: 0)]
                var year: PickerItem = pickerControl.pickerItems[1][picker.selectedRow(inComponent: 1)]
                processCard.expirationMonth = String(format: "%02d", month.value)
                processCard.expirationYear = String(format: "%02d", (year.value-2000))
                dateField.setTitle(String(format: "%02d / %04d", month.value, year.value), for: UIControlState.normal)
                checkButtonCard()
                let nextTag = picker.tag+1;
                let nextResponder = self.hostViewController.view.viewWithTag(nextTag) as UIResponder!
                if (nextResponder != nil) {
                    nextResponder?.becomeFirstResponder()
                } else {
                    picker.resignFirstResponder()
                }
            }
        }
    }
    
    private func checkButtonCard() {
        if let cardNumberField = self.hostViewController.view.viewWithTag(indexTag.card.rawValue) as? SecureUITextField {
            cardNumberField.textColor = processCard.numberValid ? UIColor.black : UIColor.red
        }
        
        if let dateField = self.hostViewController.view.viewWithTag(indexTag.date.rawValue) as? UIButton {
            dateField.tintColor = !processCard.expired ? UIColor.black : UIColor.red
        }
        
        if let cvvField = self.hostViewController.view.viewWithTag(indexTag.cvv.rawValue) as? SecureUITextField {
            cvvField.textColor = (processCard.securityCodeCheck == OPCard.OPCardSecurityCodeCheck.OPCardSecurityCodeCheckPassed) ? UIColor.black : UIColor.red
        }

        if let navigationBar = self.hostViewController.view.viewWithTag(indexTag.navBar.rawValue) as? UINavigationBar {
            let enabled = processCard.valid && (processCard.securityCodeCheck == OPCard.OPCardSecurityCodeCheck.OPCardSecurityCodeCheckPassed) && holderValid
            navigationBar.topItem?.rightBarButtonItem?.isEnabled = enabled
        }
    }
    
}




//
//  ViewController.swift
//  OpenpayExample
//
//  Created by Israel Grijalva Correa on 10/4/16.
//  Copyright © 2016 Openpay. All rights reserved.
//

import UIKit
import Openpay // 1) Import Openpay Framework

class MainViewController: UIViewController {

    
    var openpay: Openpay!
    var sessionID: String!
    var tokenID: String!
    @IBOutlet weak var blackLayer: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    static let MERCHANT_ID = "mi93pk0cjumoraf08tqt"             // Generated in Openpay account registration
    static let API_KEY = "pk_92e31f7c77424179b7cd451d21fbb771"  // Generated in Openpay account registration
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 2) Initialize Openpay instance
        //  Parameters description:
        //  withMerchantId: String - The MerchantId generated in Openpay account registration
        //  andApiKey: String - The APIKey generated in Openpay account registration
        //  isProductionMode: Bool - A flag that indicates testing or Production Mode
        //  isDebug: Bool - A flag that activate detailed console output
        openpay = Openpay(withMerchantId: MainViewController.MERCHANT_ID, andApiKey: MainViewController.API_KEY, isProductionMode: false, isDebug: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showBlackBox(show: Bool) {
        blackLayer.isHidden = !show
        activityIndicator.isHidden = !show
        continueButton.isEnabled = !show
    }


    @IBAction func sendData(_ sender: AnyObject) {
        showBlackBox(show: true)
        
        // 3) Call the createDeviceSessionId function to get the unique SessionID from the fraud prevention tool.
        //  Parameters description:
        //  successFunction: (token: OPToken) -> Void - The function to call when the request is succesfully
        //  failureFunction: (error: NSError) -> Void - The function to call when an error occurs
        openpay.createDeviceSessionId(successFunction: successSessionID, failureFunction: failSessionID)
        
    }
    
    
    /**
     * createDeviceSessionId Success Function
     */
    func successSessionID(sessionID: String) {
        showBlackBox(show: false)
        print("Success SessionID...")
        print("SessionID: \(sessionID)")
        
        self.sessionID = sessionID  // Receive in a variable the unique SessionID generated
        
        // 4) Call the loadCardForm function to display the form where the user capture his card's information. When the capture is complete, the successFunction will be called, or if an error ocurrs the failureFunction will be called.
        //  Parameters description:
        //  in: UIViewController - The current UViewController
        //  successFunction: (token: OPToken) -> Void - The function to call when the request is succesfully
        //  failureFunction: (error: NSError) -> Void - The function to call when an error occurs
        //  formTitle: String - The title displayed at the top od the form
        openpay.loadCardForm(in: self, successFunction: successCard, failureFunction: failCard, formTitle: "Openpay")
        
    }
    
    /**
     * createDeviceSessionId Failure Function
     */
    func failSessionID(error: NSError) {
        print("Fail SessionID...")
        print("\(error.code) - \(error.localizedDescription)")
//        DispatchQueue.main.sync() {
        showBlackBox(show: false)
        if let resultController = storyboard!.instantiateViewController(withIdentifier: "ResultController") as? ResultViewController {
            present(resultController, animated: true, completion: nil)
            resultController.textBox.text = String(format: NSLocalizedString("session.error", bundle: Bundle.main, comment: "Error JSON"), error.localizedDescription)
        }
//        }
    }

    
    
    
    /**
     * loadCardForm Success Function
     */
    func successCard() {
        print("Success Card Capture...")
        showBlackBox(show: true)
        
        // 5) Call the createTokenWithCard function to call the Openpay service and generate a TokenID. When the TokenID is generated, the successFunction will be called, or if an error ocurrs the failureFunction will be called.
        //  Parameters description:
        //  address: OPAddress - Optional parameter that contains de Card address
        //  successFunction: (token: OPToken) -> Void - The function to call when the request is succesfully
        //  failureFunction: (error: NSError) -> Void - The function to call when an error occurs
        
        let addressDictionary: Dictionary<String, Any> = [
            "postal_code":"76000",
            "line1":"Av 5 de Febrero",
            "line2":"Roble 207",
            "line3":"Col. Felipe",
            "city":"Querétaro",
            "state":"Querétaro",
            "country_code":"MX"
        ]
        openpay.createTokenWithCard(address: OPAddress(with: addressDictionary), successFunction: successToken, failureFunction: failToken)
    }
    
    /**
     * loadCardForm Failure Function
     */
    func failCard(error: NSError) {
        print("Fail Card Capture...")
        print("\(error.code) - \(error.localizedDescription)")
    }
    
    
    /**
     * createTokenWithCard Success Function
     */
    func successToken(token: OPToken) {
        print("Success Token...")
        print("TokenID: \(token.id)")
        DispatchQueue.main.sync() {
            showBlackBox(show: false)
            if let resultController = storyboard!.instantiateViewController(withIdentifier: "ResultController") as? ResultViewController {
                present(resultController, animated: true, completion: nil)
                resultController.textBox.text = String(format: NSLocalizedString("token.success", bundle: Bundle.main, comment: "Error JSON"), sessionID, token.id)
            }
        }
    }
    
    /**
     * createTokenWithCard Failure Function
     */
    func failToken(error: NSError) {
        print("Fail Token...")
        print("\(error.code) - \(error.localizedDescription)")
        DispatchQueue.main.sync() {
            showBlackBox(show: false)
            if let resultController = storyboard!.instantiateViewController(withIdentifier: "ResultController") as? ResultViewController {
                present(resultController, animated: true, completion: nil)
                resultController.textBox.text = String(format: NSLocalizedString("token.error", bundle: Bundle.main, comment: "Error JSON"), error.localizedDescription)
            }
        }
    }

    
    
    
    
    
    
    @IBAction func hideButtonAction(_ sender: AnyObject) {
        
        // Optionally you can make reverse search by SessionID to recover the Card's information
        //  Parameters description:
        //  tokenId: The SessionID to search
        //  successFunction: (token: OPToken) -> Void - The function to call when the request is succesfully
        //  failureFunction: (error: NSError) -> Void - The function to call when an error occurs
        openpay.getTokenWithId(tokenId: "kqm7mlkac1otx1pydi0t", successFunction: successTokenWithID, failureFunction: failToken)
    }
    
    
    func successTokenWithID(token: OPToken) {
        print("Success Token With SessionID...")
        print("SessionID: \(token.id)")
        print("Card INFO: \(token.card.number) \(token.card.type)")
        DispatchQueue.main.sync() {
            showBlackBox(show: false)
            if let resultController = storyboard!.instantiateViewController(withIdentifier: "ResultController") as? ResultViewController {
                present(resultController, animated: true, completion: nil)
                resultController.textBox.text = String(format: NSLocalizedString("tokenid.success", bundle: Bundle.main, comment: "Error JSON"), token.id, token.card.number, token.card.holderName, token.card.type.rawValue)
            }
        }
    }


}


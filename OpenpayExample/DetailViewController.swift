//
//  DetailViewController.swift
//  OpenpayExample
//
//  Created by Carlos Hernandez Perez on 22/01/21.
//

import UIKit
import OpenpayKit

class DetailViewController: UIViewController,CardTokenComplete {
    
    var openpay: Openpay!
    static let MERCHANT_ID = "mwf7x79goz7afkdbuyqd"             // Generated in Openpay account registration
    static let API_KEY = "pk_575c5a2837d94433a57cf1590bf849b0"  // Generated in Openpay account registration
    
    var sessionID: String!
    var tokenID: String!
    
    var isCustom:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Init library
        openpay = Openpay(withMerchantId: DetailViewController.MERCHANT_ID, andApiKey: DetailViewController.API_KEY, isProductionMode: false, isDebug: true,countryCode: "CO")
        
        // Get session id
        openpay.createDeviceSessionId(successFunction: successSessionID, failureFunction: failSessionID)

    }
    
    func successSessionID(sessionID: String) {
        print("Success SessionID...")
        print("SessionID: \(sessionID)")
        
        self.sessionID = sessionID  // Receive in a variable the unique SessionID generated
            
    }
    
    func successCard() {
        print("Success Card Capture...")
                
        let addressDictionary: Dictionary<String, Any> = [
            "postal_code":"76000",
            "line1":"Av 5 de Febrero",
            "line2":"Roble 207",
            "line3":"Col. Felipe",
            "city":"Querétaro",
            "state":"Querétaro",
            "country_code":"MX"
        ]
        
        // create token with card info from default form
        openpay.createTokenWithCard(address: OPAddress(with: addressDictionary), successFunction: successToken, failureFunction: failToken)
    }
    
    func successToken(token: OPToken) {
        print("Success Token...")
        print("TokenID: \(token.id)")
    }
    
    /**
     * createTokenWithCard Failure Function
     */
    func failToken(error: NSError) {
        print("Fail Token...")
        print("\(error.code) - \(error.localizedDescription)")
    }

    

    
    
    
    /**
     * loadCardForm Failure Function
     */
    func failCard(error: NSError) {
        print("Fail Card Capture...")
        print("\(error.code) - \(error.localizedDescription)")
    }
    
    
    func failSessionID(error: NSError) {
        print("Fail SessionID...")
        print("\(error.code) - \(error.localizedDescription)")
    }


    @IBAction func doPayment(_ sender: Any) {
        if isCustom! {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "customFormVC") as! CustomFormViewController
            vc.openpay = openpay
            vc.cardTokenComplete = self
            present(vc, animated: true, completion: nil)
        }else{
            openpay.loadCardForm(in: self, successFunction: successCard, failureFunction: failCard, formTitle: "Openpay")
        }
    }
    
    func onSuccessToken(token:String) -> Void {
        print("setting token value")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "resultVC") as! ResultViewController
        vc.cardTokenId = token
        present(vc, animated: true, completion: nil)
    }
    
}

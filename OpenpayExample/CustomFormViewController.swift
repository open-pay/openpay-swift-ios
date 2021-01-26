//
//  CustomFormViewController.swift
//  OpenpayExample
//
//  Created by Carlos Hernandez Perez on 24/01/21.
//

import UIKit
import OpenpayKit
import Foundation


class CustomFormViewController: UIViewController {
    var openpay: Openpay!
    
    var cardTokenComplete:CardTokenComplete?
    
    @IBOutlet weak var nameForm: UITextField!
    
    @IBOutlet weak var cardNumberForm: UITextField!
    
    @IBOutlet weak var expMonthCardForm: UITextField!
    
    @IBOutlet weak var expYearCardForm: UITextField!
    
    @IBOutlet weak var cvvCardForm: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func doPayment(_ sender: Any) {
        
        let card = TokenizeCardRequest(cardNumber: cardNumberForm.text!,holderName:nameForm.text!, expirationYear: expYearCardForm.text!, expirationMonth: expMonthCardForm.text!, cvv2: cvvCardForm.text!)
        openpay.tokenizeCard(card: card) { (OPToken) in
            print(OPToken.id)
            DispatchQueue.main.sync() {
                self.dismiss(animated: true) {
                    self.cardTokenComplete?.onSuccessToken(token: OPToken.id)
                }
            }
        } failureFunction: { (NSError) in
            print(NSError)
        }
        
    }
    
}

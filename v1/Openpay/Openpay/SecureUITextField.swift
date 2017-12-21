//
//  SecureUITextField.swift
//  Openpay
//
//  Created by Israel Grijalva Correa on 10/5/16.
//  Copyright © 2016 Openpay. All rights reserved.
//

import Foundation
import UIKit  // don't forget this

class SecureUITextField: UITextField, UITextFieldDelegate {
    
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
}

//
//  CardView.swift
//  OpenpayExample
//
//  Created by Israel Grijalva Correa on 10/5/16.
//  Copyright © 2016 Openpay. All rights reserved.
//

import UIKit

public class CardView: UIView, UITextFieldDelegate {

    class func instanceFromNib() -> UIView {
         return UINib(nibName: "CardView", bundle: Bundle(for: CardView.self)).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    

}

//
//  OPToken.swift
//  Openpay
//
//  Created by Israel Grijalva Correa on 9/28/16.
//  Copyright © 2016 Openpay. All rights reserved.
//

import Foundation

public class OPToken {
    public var id: String
    public var card: OPCard
    
    public init() {
        id = ""
        card = OPCard()
    }
    
    public init(with dictionary: Dictionary<String, Any>) {
        id = dictionary["id"] != nil ? dictionary["id"] as! String : ""
        card = OPCard(with: dictionary["card"] as! Dictionary<String, Any>)
    }
    
}

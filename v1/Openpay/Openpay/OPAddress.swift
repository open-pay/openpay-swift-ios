//
//  OPAddress.swift
//  Openpay
//
//  Created by Israel Grijalva Correa on 9/28/16.
//  Copyright © 2016 Openpay. All rights reserved.
//

import Foundation

public class OPAddress {
    
    /** Postal code. Required. */
    public var postalCode: String
    
    /** Line1 of address. Required. */
    public var line1: String
    
    /** Line2 of address. Required. */
    public var line2: String
    
    /** Line3 of address. Required. */
    public var line3: String
    
    /** City. Required. */
    public var city: String
    
    /** State. Required. */
    public var state: String
    
    /** Two-letter ISO 3166-1 country code. Optional. */
    public var countryCode: String
    
    public init() {
        postalCode = ""
        line1 = ""
        line2 = ""
        line3 = ""
        city = ""
        state = ""
        countryCode = ""
    }
    
    public init(with dictionary: Dictionary<String, Any>) {
        postalCode = dictionary["postal_code"] != nil ? dictionary["postal_code"] as! String : ""
        line1 = dictionary["line1"] != nil ? dictionary["line1"] as! String : ""
        line2 = dictionary["line2"] != nil ? dictionary["line2"] as! String : ""
        line3 = dictionary["line3"] != nil ? dictionary["line3"] as! String : ""
        city = dictionary["city"] != nil ? dictionary["city"] as! String : ""
        state = dictionary["state"] != nil ? dictionary["state"] as! String : ""
        countryCode = dictionary["country_code"] != nil ? dictionary["country_code"] as! String : ""
    }
    
    public func asDictionary() -> Dictionary<String, Any> {
        let dictionary: Dictionary = [
                                        "postal_code":postalCode,
                                        "line1":line1,
                                        "line2":line2,
                                        "line3":line3,
                                        "city":city,
                                        "state":state,
                                        "country_code":countryCode
                                     ]
        
        return dictionary
    }
    
}

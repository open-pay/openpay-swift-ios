//
//  OPCard.swift
//  Openpay
//
//  Created by Israel Grijalva Correa on 9/27/16.
//  Copyright © 2016 Openpay. All rights reserved.
//

import Foundation

public class OPCard {
    
    public enum OPCardType: Int {
        case
        OPCardTypeUnknown,
        OPCardTypeVisa,
        OPCardTypeMastercard,
        OPCardTypeAmericanExpress
    }
    
    public enum OPCardSecurityCodeCheck: Int {
        case
        OPCardSecurityCodeCheckUnknown,
        OPCardSecurityCodeCheckPassed,
        OPCardSecurityCodeCheckFailed
    }
    
    public var creationDate: NSDate
    public var id: String
    public var bankName: String
    public var allowPayouts: Bool
    public var holderName: String
    public var expirationMonth: String
    public var expirationYear: String
    public var address: OPAddress!
    public var number: String {
        didSet {
            number = number.replacingOccurrences(of: " ", with: "")
        }
    }
    public var brand: String
    public var allowsCharges: Bool
    public var bankCode: String
    public var cvv2: String
    public var errors: NSMutableArray
    
    // Read-Only Properties **************************************************
    
    public var expired: Bool {
        let cleanNumber1 = expirationMonth.replacingOccurrences(of: " ", with: "")
        let cleanNumber2 = expirationYear.replacingOccurrences(of: " ", with: "")
        if ( cleanNumber1 == "" || cleanNumber2 == "" ) { return true; }
        
        if ( Int(self.expirationMonth)! > 12 || Int(self.expirationMonth)! < 1 ) { return true; }
        
        let date = Date()
        let calendar = Calendar.current
        let currentMonth: Int = calendar.component(.month, from: date)
        let currentYear: Int = calendar.component(.year, from: date)
        
        var year: Int = Int(self.expirationYear)!
        if ( expirationYear.characters.count <= 2) {
            year += 2000;
        }
        
        if (year < currentYear) { return true; }
        
        return (year == currentYear && Int(self.expirationMonth)! < currentMonth);
    }
    
    public var type: OPCardType {
        
        let cleanNumber = number.replacingOccurrences(of: " ", with: "")
        if ( cleanNumber == "" || (cleanNumber.characters.count < 2)) {
            return OPCardType.OPCardTypeUnknown;
        }
        
        let digits: Int = Int(number.substring(to: number.index(number.startIndex, offsetBy: 2)))!
        
        if (digits >= 40 && digits <= 49) {
            return OPCardType.OPCardTypeVisa
        } else if (digits >= 50 && digits <= 59) {
            return OPCardType.OPCardTypeMastercard;
        } else if (digits == 34 || digits == 37) {
            return OPCardType.OPCardTypeAmericanExpress;
        } else {
            return OPCardType.OPCardTypeUnknown;
        }
    }

    public var numberValid: Bool {
        let cleanNumber = number.replacingOccurrences(of: " ", with: "")
        if ( cleanNumber == "" ) { return false; }
        if ( self.number.characters.count < 12 ) { return false; }
        
        var odd: Bool = true;
        var total: Int = 0;
        
        for i in stride(from: number.characters.count-1, to: -1, by: -1) {
            let start = number.index(number.startIndex, offsetBy: i)
            let end = number.index(number.startIndex, offsetBy: i+1)
            let range = start..<end
            let value: Int = Int( number.substring(with: range) )!
            odd = !odd
            total += odd ? 2 * value - (value > 4 ? 9 : 0) : value;
        }
        
        return (total % 10) == 0;
    }
    
    public var valid: Bool {
        var valid: Bool = true;
        
        if (!self.numberValid) {
            errors.add("Card number is not valid")
            valid = false;
        }
        
        if (self.expired) {
            errors.add("Card expired is not valid")
            valid = false;
        }
        
        return valid;
    }
    
    public var securityCodeCheck: OPCardSecurityCodeCheck {
        if (self.type == OPCardType.OPCardTypeUnknown) { return OPCardSecurityCodeCheck.OPCardSecurityCodeCheckUnknown; }
        let cleanCvv2 = cvv2.replacingOccurrences(of: " ", with: "")
        if (cleanCvv2 == "") {
            return OPCardSecurityCodeCheck.OPCardSecurityCodeCheckUnknown;
        }else{
            let requiredLength = (self.type==OPCardType.OPCardTypeAmericanExpress) ? 4 : 3;
            if ( self.cvv2.characters.count == requiredLength) {
                return OPCardSecurityCodeCheck.OPCardSecurityCodeCheckPassed;
            }
            else {
                return OPCardSecurityCodeCheck.OPCardSecurityCodeCheckFailed;
            }
        }
    }

    
    public init() {
        creationDate = NSDate()
        id = ""
        bankName = ""
        allowPayouts = false
        holderName = ""
        expirationMonth = ""
        expirationYear = ""
        brand = ""
        allowsCharges = false
        bankCode = ""
        cvv2 = ""
        errors = NSMutableArray()
        self.number = "0000000000000000"
    }
    
    public init(with dictionary: Dictionary<String, Any>) {
        creationDate = NSDate()
        id = ""
        bankName = ""
        allowPayouts = false
        brand = ""
        allowsCharges = false
        bankCode = ""
        errors = NSMutableArray()
        
        holderName = dictionary["holder_name"] != nil ? dictionary["holder_name"] as! String : ""
        expirationYear = dictionary["expiration_year"] != nil ? dictionary["expiration_year"] as! String : ""
        expirationMonth = dictionary["expiration_month"] != nil ? dictionary["expiration_month"] as! String : ""
        cvv2 = dictionary["cvv2"] != nil ? dictionary["cvv2"] as! String : ""
        self.number =  dictionary["card_number"] != nil ? dictionary["card_number"] as! String : "0000000000000000"
        
        if let addressDict = dictionary["address"] as? Dictionary<String, Any> {
            address = OPAddress( with: addressDict )
        }
        
        
        
    }
    
    
    public func asDictionary() -> Dictionary<String, Any> {
        var cardDictionary: Dictionary<String, Any> = [
            "card_number":self.number,
            "holder_name":self.holderName,
            "expiration_year":self.expirationYear,
            "expiration_month":self.expirationMonth,
            "cvv2":self.cvv2
        ]
        
        if self.address != nil {
            cardDictionary["address"] = self.address.asDictionary()
        }
        
        
        
        return cardDictionary
    }
    
    
}


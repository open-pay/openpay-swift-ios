//
//  PickerControl.swift
//  Openpay
//
//  Created by Israel Grijalva Correa on 10/11/16.
//  Copyright © 2016 Openpay. All rights reserved.
//

import Foundation

class PickerControl: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate  {
    
    public var pickerItems: [[PickerItem]] = [[]]
    
        
    // returns the number of 'columns' to display.
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    
    // returns the # of rows in each component..
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerItems[component].count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let item = pickerItems[component]
        return item[row].text
    }
    
    
    public func generateDates(monthLocalized: String) {
        let date = Date()
        let calendar = Calendar.current
        let currentMonth: Int = calendar.component(.month, from: date)
        let currentYear: Int = calendar.component(.year, from: date)
        var monthNames = monthLocalized.components(separatedBy: ",")
        var monthItems: [PickerItem] = []
        var yearItems: [PickerItem] = []
        
        
        if(monthNames.count > 0) {
            for i in 0...11 {
                monthItems.append( PickerItem(value:(i+1), text: "\(monthNames[i])") )
            }
            
            for i in 0...14 {
                var intYear = currentYear+i
                yearItems.append( PickerItem(value:intYear, text: "\(intYear)") )
            }
            
            pickerItems = [monthItems, yearItems]
        }
        
    }
    
    
}


struct PickerItem {
    var value: Int
    var text: String
    
    init(value: Int, text: String) {
        self.value = value
        self.text = text
    }
    
}

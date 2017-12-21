//
//  ResultViewController.swift
//  OpenpayExample
//
//  Created by Israel Grijalva Correa on 10/6/16.
//  Copyright © 2016 Openpay. All rights reserved.
//

import UIKit
import Openpay

class ResultViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var textBox: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }
    

    
}


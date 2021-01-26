//
//  ViewController.swift
//  OpenpayExample
//
//  Created by Carlos Hernandez Perez on 22/01/21.
//

import UIKit

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func defaultForm(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailVC") as! DetailViewController
        vc.isCustom=false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func customForm(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailVC") as! DetailViewController
        vc.isCustom=true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}


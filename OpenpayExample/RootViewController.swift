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
    
    @IBAction func printSwiftVersion(_ sender: Any) {
        #if swift(>=5.4)
            print("Hello, Swift 5.4")
        #elseif swift(>=5.3)
            print("Hello, Swift 5.3")
        #elseif swift(>=5.2)
            print("Hello, Swift 5.2")
        #elseif swift(>=5.1)
            print("Hello, Swift 5.1")
        #elseif swift(>=5.0)
            print("Hello, Swift 5.0")

        #elseif swift(>=4.2)
            print("Hello, Swift 4.2")

        #elseif swift(>=4.1)
            print("Hello, Swift 4.1")

        #elseif swift(>=4.0)
            print("Hello, Swift 4.0")

        #elseif swift(>=3.2)
            print("Hello, Swift 3.2")

        #elseif swift(>=3.0)
            print("Hello, Swift 3.0")

        #elseif swift(>=2.2)
            print("Hello, Swift 2.2")

        #elseif swift(>=2.1)
            print("Hello, Swift 2.1")

        #elseif swift(>=2.0)
            print("Hello, Swift 2.0")

        #elseif swift(>=1.2)
            print("Hello, Swift 1.2")

        #elseif swift(>=1.1)
            print("Hello, Swift 1.1")

        #elseif swift(>=1.0)
            print("Hello, Swift 1.0")

        #endif
    }
}


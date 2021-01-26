//
//  ResultViewController.swift
//  OpenpayExample
//
//  Created by Carlos Hernandez Perez on 25/01/21.
//

import UIKit

class ResultViewController: UIViewController {
    
    var cardTokenId:String?

    @IBOutlet weak var cardTokenIdLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        cardTokenIdLabel.text = cardTokenId
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

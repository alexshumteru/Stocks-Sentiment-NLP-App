//
//  ViewController.swift
//  StocksTweetsPredictor
//
//  Created by Alex Shum on 23/02/2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var inputTweet: UITextField!
    
    
    @IBOutlet weak var tweetURL: UITextField!
    
    @IBOutlet weak var result: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        result.text = ""
        // Do any additional setup after loading the view.
    }

   
    
}


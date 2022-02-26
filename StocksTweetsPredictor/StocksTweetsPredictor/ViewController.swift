//
//  ViewController.swift
//  StocksTweetsPredictor
//
//  Created by Alex Shum on 23/02/2022.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var inputTweet: UITextField!
    @IBOutlet weak var tweet: UITextView!
    @IBOutlet weak var tweetURL: UITextField!
    @IBOutlet weak var predict: UIButton!
    @IBOutlet weak var result: UILabel!
    
    private var model: ModelDataHandler? = ModelDataHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tweet.becomeFirstResponder()
        result.text = ""
        tweet.delegate = self
        

        // Do any additional setup after loading the view.
    }
    @IBAction func predictPressed() {
        let tweetInput: String = tweet.text!
        if tweetInput != ""{
            let wordVec = model?.preprocess(inputText: tweetInput)
            let res = model?.runModel(wordVec: wordVec!)
            result.text = res
        }
    }
    
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

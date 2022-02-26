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
    @IBOutlet weak var predict: UIButton!
    @IBOutlet weak var result: UILabel!
    
    private var model: ModelDataHandler? = ModelDataHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputTweet.becomeFirstResponder()
        result.text = ""
        inputTweet.delegate = self
        

        // Do any additional setup after loading the view.
    }
    @IBAction func predictPressed() {
        let tweetInput: String = inputTweet.text!
        if tweetInput != ""{
            let wordVec = model?.preprocess(inputText: tweetInput)
            //let output = model?.runModel(sequence: sequence)
            //let sentiment = model?.postprocess(output: output)
            //result.text = sentiment
            let res = model?.runModel(wordVec: wordVec!)
        }
    }
    
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

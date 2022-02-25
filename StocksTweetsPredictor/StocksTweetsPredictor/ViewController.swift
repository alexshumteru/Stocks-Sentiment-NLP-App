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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputTweet.becomeFirstResponder()
        result.text = ""
        inputTweet.delegate = self
        let model = ModelHandler()
        // Do any additional setup after loading the view.
        // Load Model here
    }
    @IBAction func predictPressed() {
        
        
        
        print("\(inputTweet.text)")
        
        let tweetInput: String = inputTweet.text!
        
        let test = preprocess(inputText: tweetInput)
        
        print(test)
        
        result.text = "Positive"
        
    }
    func fetchStopWords() -> [String] {
        if let path = Bundle.main.path(forResource: "stop_words", ofType: "json") {
            do {
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                  if let jsonResult = jsonResult as? Dictionary<String, [String]>, let stopWords = jsonResult["words"] {
                      return stopWords
                  }
              } catch {
                   // handle error
                  print(error)
              }
        }
        return ["load failed"]
    }
    
    func FetchWordDict() -> Dictionary<String, Int> {
        guard let path = Bundle.main.path(forResource: "word_dict", ofType: "json") else {return ["load failed": -1]}
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let wordDict = jsonResult as? Dictionary<String, Int> {
                return wordDict
            }
        } catch {
            print(error)
        }
        return ["load failed": -1]
    }
    
    
    func preprocess(inputText: String) -> [String] {
        let punct : Set<Character> = ["!", "\"", "#", "$", "%", "&", "'", "(", ")", "*", "+", ",", "-", ".", "/", ":", ";", "<", "=", ">", "?", "@", "[", "\\", "]", "^", "_", "`", "{", "|", "}", "~"]
        
        let stopWords = fetchStopWords()
        
        var inputText = inputText
        //Remove punctuation
        inputText.removeAll(where: { punct.contains($0) })
        
        //Lower the letters
        let lowerCased = inputText.lowercased()

        //Remove digits
        let digitsRemoved = lowerCased.components(separatedBy: CharacterSet.decimalDigits).joined()
        
        //split
        var listForm = digitsRemoved.components(separatedBy: " ")
        
        //Take out all the ones in stop words
        listForm = listForm.filter{ !stopWords.contains($0) }
        
        //Remove the words with with length smaller than 3
        listForm.removeAll(where: {$0.count < 3})

        
        return listForm
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

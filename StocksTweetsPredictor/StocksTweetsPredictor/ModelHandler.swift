//
//  ModelHandler.swift
//  StocksTweetsPredictor
//
//  Created by Alex Shum on 24/02/2022.
//

import TensorFlowLite
import UIKit

class ModelDataHandler: NSObject  {

  let threadCount: Int

  private var labels: [String] = ["The stock is going to go down.", "The stock is going to go up."]

  private var interpreter: Interpreter

    init?(threadCount: Int = 1) {

    // Construct the path to the model file.
      guard let modelPath = Bundle.main.path(
        forResource: "model",
        ofType: "tflite"
      ) else {
        print("Failed to load the model")
        return nil
      }
      self.threadCount = threadCount
        var options = Interpreter.Options()
      options.threadCount = threadCount
      do {
          self.interpreter = try Interpreter(modelPath: modelPath, options: options)
          try self.interpreter.allocateTensors()
      } catch let error {
        print("Failed to create the interpreter with error: \(error.localizedDescription)")
        return nil
      }
      super.init()
    }
    
    func runModel(wordVec: [Float32]) -> [Float32]? {
        let output: Tensor
        do {
            let inputTensor = try self.interpreter.input(at: 0)
            let data = Data(buffer: UnsafeBufferPointer(start: wordVec, count: wordVec.count))
            try self.interpreter.copy(data, toInputAt: 0)

            try self.interpreter.invoke()
            output = try self.interpreter.output(at: 0)
            var probabilities = Array<Float32>(repeating: 0, count: output.data.count/MemoryLayout<Float32>.stride)
            var _ = probabilities.withUnsafeMutableBytes{output.data.copyBytes(to: $0)}
            return probabilities
        } catch let error {
          print("Failed to invoke the interpreter with error: \(error.localizedDescription)")
          return nil
        }
        
    }
    
    func postprocess(probabilities: [Float32]) -> [String] {
        let maxConfidence = probabilities.max() ?? -1
        let maxIndex = probabilities.firstIndex(of: maxConfidence) ?? -1
        let stringResult = [labels[maxIndex], "with confidence: \(maxConfidence)"]
        return stringResult
    }
    
    
    private func fetchStopWords() -> [String] {
        if let path = Bundle.main.path(forResource: "stop_words", ofType: "json") {
            do {
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                  if let jsonResult = jsonResult as? Dictionary<String, [String]>, let stopWords = jsonResult["words"] {
                      return stopWords
                  }
              } catch {
                  print(error)
              }
        }
        return ["load failed"]
    }
    
    private func FetchWordDict() -> Dictionary<String, Int> {
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
    
    
    func preprocess(inputText: String) -> [Float32] {
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

        let wordDict = FetchWordDict()
        
        let wordVec = sentenceToVector(sentence: listForm, vocabDict: wordDict)

        return wordVec
    }
    
    private func sentenceToVector(sentence: [String], vocabDict: Dictionary<String,Int>, maxLength: Int = 20, unkToken: String = "__UNK__") -> [Float32]{
    
        var wordVec = [Float32]()
        let unkID = vocabDict[unkToken]
        var wordID: Int?
        for word in sentence{
            wordID = vocabDict[word]
            if wordID == nil{
                wordID = unkID
            }
            wordVec.append(Float(wordID!))
        }
        let currLength = wordVec.count
        for _ in stride(from: currLength, to: maxLength, by: 1){
            wordVec.append(0.0)
        }
        return wordVec
    }
    
}

extension Data {
  init<T>(copyingBufferOf array: [T]) {
    self = array.withUnsafeBufferPointer(Data.init)
  }
}

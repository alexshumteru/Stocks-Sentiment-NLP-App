//
//  ModelHandler.swift
//  StocksTweetsPredictor
//
//  Created by Alex Shum on 24/02/2022.
//

import TensorFlowLite
import UIKit

class ModelHandler {

  let threadCount: Int

  let batchSize = 1
    
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
    var options = InterpreterOptions()
    options.threadCount = threadCount
    do {
      interpreter = try Interpreter(modelPath: modelPath, options: options)
      try interpreter.allocateTensors()
    } catch let error {
      print("Failed to create the interpreter with error: \(error.localizedDescription)")
      return nil
    }
  }
}

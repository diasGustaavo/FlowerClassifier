//
//  FlowerClassifierManager.swift
//  FlowerClassifier
//
//  Created by Gustavo Dias on 11/01/23.
//

import Foundation
import CoreML
import Vision
import CoreImage

protocol FlowerClassifierManagerDelegate {
    func didClassified(_ flowerInfoManager: FlowerClassifierManager, flower: String)
    func didNotClassifyWithError(error: Error)
}

struct FlowerClassifierManager {
    var image: CIImage?
    var delegate: FlowerClassifierManagerDelegate?
    
    mutating func setImage(image: CIImage) {
        self.image = image
    }
    
    func detect() {
        if let safeImage = image {
            let config = MLModelConfiguration()
            guard let model = try? VNCoreMLModel(for: FlowerClassifier(configuration: config).model) else {
                fatalError("Loading CoreML Model Failed.")
            }
            
            let request = VNCoreMLRequest(model: model) { request, error in
                if let results = request.results as? [VNClassificationObservation] {
                    if let firstResult = results.first {
                        delegate?.didClassified(self, flower: firstResult.identifier)
                    }
                }
            }
            
            let handler = VNImageRequestHandler(ciImage: safeImage)
            
            do {
                try handler.perform([request])
            } catch {
                delegate?.didNotClassifyWithError(error: error)
            }
        } else {
            print("error getting image, use setImage(image: CIImage) method first.")
        }
    }
}


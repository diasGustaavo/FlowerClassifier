//
//  FlowerInfoManager.swift
//  FlowerClassifier
//
//  Created by Gustavo Dias on 10/01/23.
//

import Foundation
import SwiftyJSON

protocol FlowerInfoManagerDelegate {
    func didGetInfo(_ flowerInfoManager: FlowerInfoManager, flower: FlowerModel)
    func didFailWithError(error: Error)
}

struct FlowerInfoManager {
    var flowerName: String?
    var flowerURL: String {
        return "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles=\(flowerName!)&indexpageids&redirects=1"
    }
    
    var flowerImageURL: String {
        return "https://en.wikipedia.org/w/api.php?action=query&format=json&formatversion=2&prop=pageimages|pageterms&piprop=thumbnail&pithumbsize=500&titles=\(flowerName!)"
    }
    var delegate: FlowerInfoManagerDelegate?
    
    mutating func fetchFlowerInfo(flowerName: String) {
        if flowerName == "thorn apple" {
            self.flowerName = "Datura%20stramonium"
        } else {
            self.flowerName = flowerName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }
        
        performRequest()
    }
//
    func performRequest() {
        // 1. Create URL
        var flower = FlowerModel()
        
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .default).async {
            print(flowerURL)
            if let url = URL(string: flowerURL) {
                // 2. Create URLSession
                let session = URLSession(configuration: .default)

                // 3. Give the session a task
                let task = session.dataTask(with: url) { data, response, error in
                    if error != nil {
                        delegate?.didFailWithError(error: error!)
                        return
                    }
                    if let safeData = data {
                        if let flowerReceived = parseJSONFlower(safeData) {
                            flower.title = flowerReceived.title
                            flower.extract = flowerReceived.extract
                            group.leave()
                        }
                    }
                }

                // 4. Start the task
                task.resume()
            }
        }
        
        group.wait()
        
        var urlStringImage = flowerURL
        urlStringImage += "&prop=pageimages&pithumbsize=500"
        
        if let url = URL(string: urlStringImage) {
            // 2. Create URLSession
            let session = URLSession(configuration: .default)

            // 3. Give the session a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let link = parseJSONLink(safeData) {
                        flower.imageLink = link
                        delegate?.didGetInfo(self, flower: flower)
                    }
                }
            }

            // 4. Start the task
            task.resume()
        }
    }

    func parseJSONFlower(_ flowerData: Data) -> FlowerModel? {
        if let json = try? JSON(data: flowerData) {
            if let pageId = json["query"]["pageids"][0].string {
                return FlowerModel(title: json["query"]["pages"][pageId]["title"].stringValue, extract: json["query"]["pages"][pageId]["extract"].stringValue)
            }
        }
        return nil
    }
    
    func parseJSONLink(_ flowerData: Data) -> URL? {
        if let json = try? JSON(data: flowerData) {
            if let pageId = json["query"]["pageids"][0].string {
                return URL(string: json["query"]["pages"][pageId]["thumbnail"]["source"].stringValue)
            }
        }
        return nil
    }
}

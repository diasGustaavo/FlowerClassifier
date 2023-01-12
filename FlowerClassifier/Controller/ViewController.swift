//
//  ViewController.swift
//  FlowerClassifier
//
//  Created by Gustavo Dias on 09/01/23.
//

import UIKit
import SDWebImage

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var extractLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    var flowerClassifierManager = FlowerClassifierManager()
    var flowerManager = FlowerInfoManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        flowerManager.delegate = self
        flowerClassifierManager.delegate = self
    }
    
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

extension ViewController: FlowerClassifierManagerDelegate {
    func didClassified(_ flowerInfoManager: FlowerClassifierManager, flower: String) {
        navigationItem.title = flower.capitalized
        flowerManager.fetchFlowerInfo(flowerName: flower)
    }
    
    func didNotClassifyWithError(error: Error) {
        print("error")
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not UIImage to CIImage")
            }
            flowerClassifierManager.setImage(image: ciimage)
            flowerClassifierManager.detect()
        }
        
        imagePicker.dismiss(animated: true)
    }
}

extension ViewController: FlowerInfoManagerDelegate {
    func didGetInfo(_ flowerInfoManager: FlowerInfoManager, flower: FlowerModel) {
        DispatchQueue.main.async {
            if let safeExtractLabel = flower.extract {
                print(safeExtractLabel)
                self.extractLabel.text = safeExtractLabel
            }
            if let flowerURL = flower.imageLink {
                print(flowerURL)
                self.imageView.sd_setImage(with: flowerURL)
            }
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}


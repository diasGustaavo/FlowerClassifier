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
        
        let newNavBarAppearance = customNavBarAppearance()
        navigationController!.navigationBar.scrollEdgeAppearance = newNavBarAppearance
        navigationController!.navigationBar.compactAppearance = newNavBarAppearance
        navigationController!.navigationBar.standardAppearance = newNavBarAppearance
        if #available(iOS 15.0, *) {
            navigationController!.navigationBar.compactScrollEdgeAppearance = newNavBarAppearance
        }
    
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        flowerManager.delegate = self
        flowerClassifierManager.delegate = self
    }
    
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func libraryButtonPressed(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func customNavBarAppearance() -> UINavigationBarAppearance {
        let customNavBarAppearance = UINavigationBarAppearance()
        
        customNavBarAppearance.configureWithOpaqueBackground()
        if self.traitCollection.userInterfaceStyle == .dark {
            customNavBarAppearance.backgroundColor = UIColor(red: 0.38, green: 0.42, blue: 0.22, alpha: 1.00)
        } else {
            customNavBarAppearance.backgroundColor = UIColor(red: 0.16, green: 0.21, blue: 0.09, alpha: 1.00)
        }

        
        // Apply white colored normal and large titles.
        customNavBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(named: "accentYellow")!]
        customNavBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "accentYellow")!]

        // Apply white color to all the nav bar buttons.
        let barButtonItemAppearance = UIBarButtonItemAppearance(style: .plain)
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        barButtonItemAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.lightText]
        barButtonItemAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.label]
        barButtonItemAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.white]
        customNavBarAppearance.buttonAppearance = barButtonItemAppearance
        customNavBarAppearance.backButtonAppearance = barButtonItemAppearance
        customNavBarAppearance.doneButtonAppearance = barButtonItemAppearance
        
        return customNavBarAppearance
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
                self.extractLabel.text = safeExtractLabel
            }
            if let flowerURL = flower.imageLink {
                self.imageView.sd_setImage(with: flowerURL)
            }
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}


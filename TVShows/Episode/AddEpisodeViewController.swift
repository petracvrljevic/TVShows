//
//  AddEpisodeViewController.swift
//  TVShows
//
//  Created by Petra Cvrljevic on 13/09/2018.
//  Copyright © 2018 Petra Cvrljevic. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Alamofire

protocol EpisodeDelegate: class {
    func episodeAdded()
}

class AddEpisodeViewController: UIViewController {
    
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var episodeTitleTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var seasonEpisodeTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var episodeDescriptionTextField: SkyFloatingLabelTextField!

    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    let imagePicker = UIImagePickerController()
    var path: URL?
    var imagePicked = false
    
    var showID: String?
    
    weak var delegate: EpisodeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
    }
    
    func setupNavigation() {
        self.navigationItem.backBarButtonItem = nil
        self.navigationItem.title = "Add episode"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(handleAddEpisode))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        self.navigationItem.rightBarButtonItem?.tintColor = Helper.pinkColor
        self.navigationItem.leftBarButtonItem?.tintColor = Helper.pinkColor
    }

    @objc func handleAddEpisode() {
        
        guard let showID = showID else { return }
        
        if imagePicked, let imagePath = path {
            APIHelper().uploadImage(url: APIHelper.uploadImageURL, imageURL: imagePath) { (id) in
                if id != "" {

                    self.uploadEpisode(showID: showID, withMedia: true, mediaID: id)
                    
                }
                else {
                    self.uploadEpisode(showID: showID, withMedia: false, mediaID: "")
                }
            }
        }
        else {
            self.uploadEpisode(showID: showID, withMedia: false, mediaID: "")
        }
    }
    
    func uploadEpisode(showID: String, withMedia: Bool, mediaID: String) {
        if let title = episodeTitleTextField.text, let description = episodeDescriptionTextField.text, !title.isEmpty && !description.isEmpty {
            if let seasonEpisodeText = seasonEpisodeTextField.text, !seasonEpisodeText.isEmpty {
                
                let numbers = numbersFromString(text: seasonEpisodeText)
                
                if numbers.count == 2 {
                    let season = numbers[0]
                    let episode = numbers[1]
                    
                    let params: Parameters
                    
                    if withMedia, mediaID != "" {
                        params = ["showId": showID,
                                  "mediaId": mediaID,
                                  "title": title,
                                  "description": description,
                                  "episodeNumber": "\(episode)",
                            "season": "\(season)"]
                    }
                    else {
                        params = ["showId": showID,
                                  "title": title,
                                  "description": description,
                                  "episodeNumber": "\(episode)",
                            "season": "\(season)"]
                    }
                    
                    APIHelper().addEpisode(url: APIHelper.createEpisodeURL, params: params) { (success) in
                        if success {
                            self.navigationController?.popViewController(animated: true)
                            self.delegate?.episodeAdded()
                        }
                        else {
                            Helper().showErrorAlertWithMessage(message: "Error with adding episode!", view: self)
                        }
                    }
                }
                else {
                    Helper().showErrorAlertWithMessage(message: "Bad input!", view: self)
                }
            }
            else {
                Helper().showErrorAlertWithMessage(message: "Please enter season and episode numbers!", view: self)
            }
        }
        else {
            Helper().showErrorAlertWithMessage(message: "Please enter title/description!", view: self)
        }
    }
    
    func numbersFromString(text: String) -> [Int] {
        var numbers = [Int]()
        let stringArray = text.components(separatedBy: CharacterSet.decimalDigits.inverted)
        for item in stringArray {
            if let number = Int(item) {
                numbers.append(number)
            }
        }
        return numbers
    }
    
    @objc func handleCancel() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func uploadPhotoTapped(_ sender: UIButton) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        let pickerSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        pickerSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert: UIAlertAction) in
            self.showCamera()
        }))
        pickerSheet.addAction(UIAlertAction(title: "Photo library", style: .default, handler: { (alert: UIAlertAction) in
            self.showPhotoLibrary()
        }))
        pickerSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(pickerSheet, animated: true, completion: nil)
    }
    
    private func showCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func showPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
    }

}

extension AddEpisodeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let imgUrl = info[UIImagePickerControllerImageURL] as? URL{
            let imgName = imgUrl.lastPathComponent
            if let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
                
                let localPath = documentDirectory.appending(imgName)
                
                if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let data = UIImagePNGRepresentation(pickedImage) as NSData? {
                    
                    data.write(toFile: localPath, atomically: true)
                    let photoURL = URL.init(fileURLWithPath: localPath)
                    self.path = photoURL
                    episodeImageView.contentMode = .scaleAspectFit
                    imageWidthConstraint.constant = 200
                    imageHeightConstraint.constant = 200
                    episodeImageView.image = pickedImage
                    imagePicked = true
                }
                
            }
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

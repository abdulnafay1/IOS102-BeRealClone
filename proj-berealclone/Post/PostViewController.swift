//
//  PostViewController.swift
//  proj-berealclone
//
//  Created by Nafay on 2/1/24.
//

import UIKit
import PhotosUI
import ParseSwift

class PostViewController: UIViewController {

    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet var captionTextField: UITextField!
    @IBOutlet var previewImageView: UIImageView!
    
    private var pickedImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewImageView.isHidden = true

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onPickedImageTapped(_ sender: Any) {
        
        var config = PHPickerConfiguration()

        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    

    @IBAction func onShareTapped(_ sender: Any) {
        
        // Dismiss Keyboard
        view.endEditing(true)
        
        guard let image = pickedImage,
              let imageData = image.jpegData(compressionQuality: 0.1) else {
            return
        }
        
        let imageFile = ParseFile(name: "image.jpg", data: imageData)
        var post = Post()
        
        post.imageFile = imageFile
        post.caption = captionTextField.text
        post.user = User.current
        
        post.save { [weak self] result in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let post):
                    print("✅ Post Saved! \(post)")
                    
                    // Return to previous view controller
                    self?.navigationController?.popViewController(animated: true)
                    
                case .failure(let error):
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }
    }

    
    
    //@IBAction func onViewTapped(_ sender: Any) {
        // Dismiss keyboard
       // view.endEditing(true)
    //}
    
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }

}

extension PostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // Dismiss the picker
        picker.dismiss(animated: true)

        // Make sure we have a non-nil item provider
        guard let provider = results.first?.itemProvider,
           // Make sure the provider can load a UIImage
           provider.canLoadObject(ofClass: UIImage.self) else { return }

        // Load a UIImage from the provider
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in

           // Make sure we can cast the returned object to a UIImage
           guard let image = object as? UIImage else {

              // ❌ Unable to cast to UIImage
              self?.showAlert()
              return
           }

              // UI updates (like setting image on image view) should be done on main thread
              DispatchQueue.main.async {

                 // Set image on preview image view
                  self?.previewImageView.image = image
                  self?.previewImageView.isHidden = false
                  self?.previewImageView.layer.cornerRadius = 10
                  self?.previewImageView.layer.masksToBounds = true

                 // Set image to use when saving post
                 self?.pickedImage = image
              }
           }
        }
}

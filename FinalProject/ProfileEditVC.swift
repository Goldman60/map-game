//
//  profileEditVC.swift
//  FinalProject
//
//  Created by AJ Fite on 5/20/18.
//  Copyright © 2018 AJ Fite. All rights reserved.
//

//TODO: Image

import UIKit
import Photos
import Firebase

class ProfileEditVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var favPlaceTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    
    var imagesRef  :  StorageReference!
    
    var userData : PublicUserData?
    
    @IBAction func replaceImagePressed(_ sender: Any) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        
        present(picker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagesRef = Storage.storage().reference().child("profileimages")
        
        if Auth.auth().currentUser != nil { // User is happily logged in
            usernameTextField.text = userData?.username
            favPlaceTextField.text = userData?.favPlace
            
            let userImage = self.imagesRef.child(userData!.profilePhotoShortKey)
            
            userImage.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let _ = error {
                    print(error!.localizedDescription)
                } else {
                    // Data for "images/island.jpg" is returned
                    self.profileImage.image = UIImage(data: data!)
                }
            }
        }
        else { // User is not logged in for whatever reason
            performSegue(withIdentifier: "unwindFromCancel", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textFieldShouldEndEditing(textField)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "unwindFromSave") {
            let vc = segue.destination as? ProfileVC
            
            
            if profileImage.image != nil {
                doPhotoWork()
            }
            
            userData?.favPlace = favPlaceTextField.text ?? ""
            userData?.username = usernameTextField.text ?? ""
            
            vc?.publicUserData = userData!
        }
    }
    
    func doPhotoWork() {        
        if let user = Auth.auth().currentUser { // User is happily logged in
            let photoInfo = PhotoInfo(title: user.uid)
            
            userData?.profilePhotoKey = photoInfo.photoKey;
            
            let imageData = UIImageJPEGRepresentation(profileImage.image!, 0.1)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let imagePath = userData!.profilePhotoShortKey
            
            self.imagesRef.child(imagePath).putData(imageData!, metadata: metadata) {
                (metadata, error) in
                
                if let error = error {
                    print("Error uploading: \(error.localizedDescription)")
                }
                else {
                    self.imagesRef.child(imagePath).downloadURL(completion: {
                        (url, error) in
                        
                        guard let downloadURL = url else {
                            print("ERROR with images")
                            return
                        }
                        
                        let publicDatabaseRef = Database.database().reference().child("publicusers")
                        
                        print("Storing data \(downloadURL.absoluteString)")
                        
                        self.userData?.profilePhotoKey = downloadURL.absoluteString
                        
                        let editUserRef = publicDatabaseRef.child(self.userData!.key)
                        editUserRef.setValue(self.userData!.toAnyObject())
                    })
                }
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate methods
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        
        profileImage.image = image
        
        picker.dismiss(animated: true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }

}

//
//  DoCheckInVC.swift
//  FinalProject
//
//  Created by AJ Fite on 5/29/18.
//  Copyright © 2018 AJ Fite. All rights reserved.
//

import UIKit
import Photos
import Firebase

class DoCheckInVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var databaseRef : DatabaseReference!
    var imagesRef  :  StorageReference!
    var checkInRef : StorageReference!
    var checkInPlaceID: String?
    
    @IBOutlet weak var checkInPhoto: UIImageView!
    @IBOutlet weak var completeCheckInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference().child("checkIn")
        imagesRef = Storage.storage().reference().child("checkInImages")
        checkInRef = Storage.storage().reference().child("publicUserData")
        
        completeCheckInButton.isEnabled = false

        // Do any additional setup after loading the view.
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        
        present(picker, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIImagePickerControllerDelegate methods
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        
        checkInPhoto.image = image
        
        if checkInPhoto.image != nil {
            completeCheckInButton.isEnabled = true
        }
        
        picker.dismiss(animated: true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        // Set up stamps for storage
        let dateFormatter = DateFormatter()
        let date = Date()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateStamp = dateFormatter.string(from: date)
        let photoStamp = user.uid + checkInPlaceID! + dateStamp
        
        if segue.identifier == "unwindFromSave" {
            let photoInfo = PhotoInfo(title: photoStamp)
            
            let newPhotoInfoRef = databaseRef.child(user.uid).child(dateStamp + checkInPlaceID!)
            newPhotoInfoRef.setValue(photoInfo.toAny())
            
            let imageData = UIImageJPEGRepresentation(checkInPhoto.image!, 0.1)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let imagePath = user.uid + checkInPlaceID! + ".jpeg"
            print(imagePath)
            
            self.imagesRef.child(imagePath).putData(imageData!, metadata: metadata) { (metadata, error) in
                
                if let error = error {
                    print("Error uploading: \(error) for image: \(imagePath)")
                }
                else {
                    self.imagesRef.child(imagePath).downloadURL(completion: { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            return
                        }
                        
                        print("Image uploaded at \(downloadURL.absoluteString)")
                        // version without callback - can use either one
                        //                    newPhotoInfoRef.updateChildValues(["photoKey" : url])
                        newPhotoInfoRef.updateChildValues(["photoKey" : downloadURL.absoluteString])
                        { error, databaseRef in
                            if let error = error {
                                print("Error updating image URL: \(error)")
                            }
                            else {
                                print("Image URL successfully updated.")
                            }
                        }
                    }
                )}
            }
        }
    }
}

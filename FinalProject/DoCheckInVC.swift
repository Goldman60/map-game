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

    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference().child("photoInfo")
        imagesRef = Storage.storage().reference().child("images")

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var checkInPhoto: UIImageView!
    
    @IBAction func completeCheckIn(_ sender: Any) {
        
    
        
        let photoInfo = PhotoInfo(title: "Test Image")
        
        let newPhotoInfoRef = databaseRef.child("Test Image")
        newPhotoInfoRef.setValue(photoInfo.toAny())
        
        let imageData = UIImageJPEGRepresentation(checkInPhoto.image!, 1.0)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let imagePath = "Test Image" + ".jpeg"
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
        
        picker.dismiss(animated: true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

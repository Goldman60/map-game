//
//  SecondViewController.swift
//  FinalProject
//
//  Created by AJ Fite on 5/19/18.
//  Copyright © 2018 AJ Fite. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

//Login and other related tasks accomplished here
class ProfileVC: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userPlaceLabel: UILabel!
    @IBOutlet weak var userImageLabel: UIImageView!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var editUserLabel: UIButton!
    @IBOutlet weak var userRealNameLabel: UILabel!
    
    var publicUserData: PublicUserData = PublicUserData()
    
    var handle : AuthStateDidChangeListenerHandle?
    
    var publicDatabaseRef : DatabaseReference!
    var imagesRef  :  StorageReference!
    
    @IBAction func signInButtonPressed(_ sender: GIDSignInButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            GIDSignIn.sharedInstance().disconnect() //Kill the oauth token so the user doesn't stay signed in in the background
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func unwindFromSave(segue:UIStoryboardSegue) {
        let editUserRef = self.publicDatabaseRef.child(publicUserData.key)
        editUserRef.setValue(publicUserData.toAnyObject())
    }
    
    @IBAction func unwindFromCancel(segue:UIStoryboardSegue) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.reloadAuthData()
        }
    }
    
    func reloadAuthData() {
        if let user = Auth.auth().currentUser {
            publicDatabaseRef = Database.database().reference().child("publicusers")
            imagesRef = Storage.storage().reference().child("images")
            
            self.publicDatabaseRef?.queryOrderedByKey().queryEqual(toValue: user.uid).observe(.value, with: {snapshot in
                
                self.publicUserData = PublicUserData(key:user.uid, snapshot:snapshot)
            })
            
            if self.publicUserData.key == "" {
                self.publicUserData = PublicUserData(key: user.uid)
            }
            
            googleSignInButton.isHidden = true
            logoutButton.isHidden = false
            editUserLabel.isHidden = false
            
            usernameLabel.text = publicUserData.username
            userPlaceLabel.text = publicUserData.favPlace
            userEmailLabel.text = user.email
            userRealNameLabel.text = user.displayName
        }
        else {
            googleSignInButton.isHidden = false
            logoutButton.isHidden = true
            editUserLabel.isHidden = true
            
            userEmailLabel.text = "SIGNED OUT"
            userRealNameLabel.text = "SIGNED OUT"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Auth.auth().removeStateDidChangeListener(handle!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "editProfileSegue") {
            let vc = segue.destination as? ProfileEditVC
            
            vc?.userData = publicUserData
        }
    }
}


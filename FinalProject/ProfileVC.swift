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
    
    var handle : AuthStateDidChangeListenerHandle?
    
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
            googleSignInButton.isHidden = true
            logoutButton.isHidden = false
            editUserLabel.isHidden = false
            
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
}


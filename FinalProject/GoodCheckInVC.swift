//
//  GoodCheckInVC.swift
//  FinalProject
//
//  Created by AJ Fite on 5/21/18.
//  Copyright © 2018 AJ Fite. All rights reserved.
//

import UIKit
import Firebase

class GoodCheckInVC: UIViewController {
    
    var destPlace: Place?
    var metaPlaceUser: MetaPlaceUser?
    var handle : AuthStateDidChangeListenerHandle?

    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var lastCheckInLabel: UILabel!
    @IBOutlet weak var totalCheckInCount: UILabel!
    
    @IBOutlet weak var ownerUsername: UILabel!
    @IBOutlet weak var ownerFavPlace: UILabel!
    @IBOutlet weak var ownerCheckInCount: UILabel!
    @IBOutlet weak var ownerImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if auth.currentUser != nil {
                self.checkInButton.isEnabled = true
            }
            else {
                self.checkInButton.isEnabled = false
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Auth.auth().removeStateDidChangeListener(handle!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindFromSave(segue:UIStoryboardSegue) {
    }
    
    @IBAction func unwindFromCancel(segue:UIStoryboardSegue) {
    }
    
    @IBAction func doCheckIn(_ sender: UIButton) {
        // Production interval
        let oneHour = Calendar.current.date(
            byAdding: .hour,
            value: -1,
            to: Date())
        let oneHourInSeconds = 3600.0
        
        // Debug interval
        let threeMinutes = Calendar.current.date(
            byAdding: .minute,
            value: -3,
            to: Date())
        let threeMinutesInSeconds = 180.0
        
        if metaPlaceUser!.lastCheckIn!.timeIntervalSince(threeMinutes!) > 0 {
            let dialog = UIAlertController(title: "Too Soon", message: "You checked in here recently! Wait \(String(format: "%.0f", metaPlaceUser!.lastCheckIn!.timeIntervalSinceNow + threeMinutesInSeconds)) seconds", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Try Again Later", style: .cancel, handler: nil)
            dialog.addAction(action)
            
            present(dialog, animated: true, completion: nil)
        }
        else {
            performSegue(withIdentifier: "doCheckInSegue", sender: self)
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "doCheckInSegue" {
            let destVC = segue.destination as? DoCheckInVC
            destVC?.checkInPlaceID = destPlace?.key
        }
    }

}

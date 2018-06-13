//
//  AchievementsVC.swift
//  FinalProject
//
//  Created by AJ Fite on 6/12/18.
//  Copyright © 2018 AJ Fite. All rights reserved.
//

import UIKit
import Firebase

class AchievementsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var imagesRef: StorageReference!
    var userData: PublicUserData?
    
    var databasePlacesRef: DatabaseReference?
    
    @IBOutlet weak var totalCheckInLabel: UILabel!
    @IBOutlet weak var mostVisitedLabel: UILabel!
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recentImageCell", for: indexPath) as! RecentCheckInCell
        
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        imagesRef = Storage.storage().reference().child("checkInImages")
        
        //Retrieve most checked in place
        databasePlacesRef = Database.database().reference().child("places")
        
        databasePlacesRef?.queryOrderedByKey().queryEqual(toValue: userData?.mostCheckedInPlace).observeSingleEvent(of: .value, with: { snapshot in
            if let _ = snapshot.value as? [String : AnyObject] {
                let place = Place(key: self.userData!.mostCheckedInPlace, snapshot: snapshot)
                
                self.mostVisitedLabel.text = place.name
            }
            else {
                self.mostVisitedLabel.text = "None!"
            }
        })
        
        totalCheckInLabel.text = String(userData!.checkInCount)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

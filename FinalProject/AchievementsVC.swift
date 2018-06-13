//
//  AchievementsVC.swift
//  FinalProject
//
//  Created by AJ Fite on 6/12/18.
//  Copyright © 2018 AJ Fite. All rights reserved.
//

import UIKit
import Firebase

// Due to time constraints this class has unfinished features
class AchievementsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    var imagesRef: StorageReference!
    var userData: PublicUserData?
    
    @IBOutlet weak var ownerPlaceTable: UITableView!
    @IBOutlet weak var checkInCollection: UICollectionView!
    
    var databasePlacesRef: DatabaseReference!
    var checkInsRef: DatabaseReference!
    
    var checkInCount: Int = 0
    
    var recentCheckIns: [UIImage] = [UIImage]()
    
    @IBOutlet weak var totalCheckInLabel: UILabel!
    @IBOutlet weak var mostVisitedLabel: UILabel!
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return checkInCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recentImageCell", for: indexPath) as! RecentCheckInCell
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeOwnerCell", for: indexPath) as! PlaceOwnerCell
        
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
        
        //Recent Check ins
        /* TODO: Time constraints, feature not implemented
        checkInsRef = Database.database().reference().child("checkIn").child((userData?.key)!)
        
        checkInsRef.queryOrderedByKey().queryLimited(toLast: 10).observe(.childChanged, with: { snapshot in
            self.recentCheckIns = [UIImage]()
            
            for child in snapshot.children {
                let data = child as? DataSnapshot
                
                
                
            }
            
            checkInCount = snapshot.childrenCount
            
            
        })
        */
        
        totalCheckInLabel.text = String(userData!.checkInCount)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

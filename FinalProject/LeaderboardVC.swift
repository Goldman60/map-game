//
//  LeaderboardVC.swift
//  FinalProject
//
//  Created by AJ Fite on 5/20/18.
//  Copyright © 2018 AJ Fite. All rights reserved.
//

import UIKit
import Firebase

class LeaderboardVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: DatabaseReference!
    var usernameRef: DatabaseReference!

    var sectionCount: Int = 0
    
    var points: [Int] = [Int]()
    var userID: [String] = [String]()
    var userName: [String] = [String]()
    
    @IBOutlet weak var table: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leader", for: indexPath) as? LeaderboardCell
        
        cell?.indexLabel.text = String(indexPath.row + 1)
        cell?.usernameLabel.text = userName[sectionCount - indexPath.row - 1]
        cell?.pointsLabel.text = String(points[sectionCount - indexPath.row - 1])
        
        return cell!
    }
    
    override func viewDidLoad() { //TODO: Make the leadearboard a bit less fragile
        super.viewDidLoad()
        
        ref = Database.database().reference().child("leaderboard")
        usernameRef = Database.database().reference().child("publicusers")
        
        self.ref.queryOrderedByValue().queryLimited(toLast: 20).observe(.value, with: { (snapshot: DataSnapshot) in
            
            print("Retrieving Data")
            
            self.sectionCount = Int(snapshot.childrenCount)

            var counter: Int = 0
            for child in snapshot.children {
                print("Retrieving Data for \(String(counter))")

                let data = child as! DataSnapshot
                let key = data.key
                let value = data.value as! Int
                
                self.points.insert(value, at: counter)
                self.userID.insert(key, at: counter)
                self.userName.insert("", at: counter)
                
                counter += 1
            }
            
            self.table.reloadData()
            
            for id in self.userID {
                self.usernameRef.child(id).child("username").observeSingleEvent(of: .value, with: {snapshot in
                    
                    let username = snapshot.value as? String
                    let index = self.userID.index(of: (snapshot.ref.parent?.key)!)
                    
                    self.userName.insert(username ?? "Anonymous User", at: index!)
                    
                    print("Attempting to fill " + (snapshot.ref.parent?.key)!)
                    
                    self.table.reloadRows(at: [IndexPath(item: self.sectionCount - index! - 1, section: 0)], with: .fade)
                })
            }
        })

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

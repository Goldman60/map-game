//
//  CheckInVC.swift
//  FinalProject
//
//  Created by AJ Fite on 5/20/18.
//  Copyright © 2018 AJ Fite. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class CheckInVC: UIViewController, CLLocationManagerDelegate {
    
    var destPlace: Place?

    @IBOutlet weak var bottomHalfView: UIView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    
    var publicDatabaseRef : DatabaseReference!
    var metaPlaceUser: MetaPlaceUser?
    var ownerData: PublicUserData?
    var metaplaceRef: DatabaseReference!
    var metaplaceOwnerRef: DatabaseReference!
    var imagesRef: StorageReference!

    
    var handle : AuthStateDidChangeListenerHandle?
    
    private let topStackView = UIStackView()
    fileprivate lazy var goodCheckInVC: GoodCheckInVC = buildFromStoryboard("Main")
    fileprivate lazy var badCheckInVC: BadCheckInVC = buildFromStoryboard("Main")
    let locationManager = CLLocationManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if auth.currentUser != nil {
                self.bottomHalfView.isHidden = false
            }
            else {
                self.bottomHalfView.isHidden = true
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Auth.auth().removeStateDidChangeListener(handle!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLocationManager()
        
        //Setup child views for bottom
        addChildViewController(goodCheckInVC)
        addChildViewController(badCheckInVC)
        
        bottomHalfView.addSubview(goodCheckInVC.view)
        bottomHalfView.addSubview(badCheckInVC.view)
        
        goodCheckInVC.destPlace = destPlace
        
        goodCheckInVC.didMove(toParentViewController: self)
        badCheckInVC.didMove(toParentViewController: self)

        bottomHalfView.bringSubview(toFront: badCheckInVC.view)
        
        placeNameLabel.text = destPlace?.name
        categoryLabel.text = destPlace?.category
        
        metaplaceRef = Database.database().reference().child("metaplaces")
        metaplaceOwnerRef = Database.database().reference().child("metaplaces-owners")
        publicDatabaseRef = Database.database().reference().child("publicusers")
        imagesRef = Storage.storage().reference().child("profileimages")
        
        if let user = Auth.auth().currentUser {
            // Gets your last check in
            metaplaceRef.child(destPlace!.key).queryOrderedByKey().queryEqual(toValue: user.uid).observe(.value, with: {snapshot in
                if snapshot.hasChildren() {
                    self.metaPlaceUser = MetaPlaceUser(key:user.uid, snapshot:snapshot)
                    
                    self.goodCheckInVC.lastCheckInLabel.text = self.metaPlaceUser!.lastCheckIn?.description
                    self.goodCheckInVC.totalCheckInCount.text = String(self.metaPlaceUser!.checkInCount)
                }
                else {
                    print("Making new meta place")
                    self.metaPlaceUser = MetaPlaceUser()
                    
                    self.goodCheckInVC.lastCheckInLabel.text = "Never!"
                    self.goodCheckInVC.totalCheckInCount.text = "0"
                }
                
                self.goodCheckInVC.metaPlaceUser = self.metaPlaceUser
            })
            
            // Gets current place owner
            metaplaceOwnerRef.queryOrderedByKey().queryEqual(toValue: destPlace!.key).observe(.value, with: {snapshot in
                if let snaptemp = snapshot.value as? [String : AnyObject] {
                    let snapvalues = snaptemp[self.destPlace!.key] as! [String : AnyObject]
                    
                    self.goodCheckInVC.ownerCheckInCount.text = String(snapvalues["checkInCount"] as? Int ?? 0)
                    
                    if let ownerID = snapvalues["ownerID"] as? String {
                    self.publicDatabaseRef?.queryOrderedByKey().queryEqual(toValue: ownerID).observe(.value, with: {snapshotOwner in
                            if let _ = snapshotOwner.value as? [String : AnyObject] {
                                self.ownerData = PublicUserData(key: user.uid, snapshot: snapshotOwner)
                            }
                            else {
                                self.ownerData = PublicUserData(key: user.uid)
                            }
                        
                            self.goodCheckInVC.ownerFavPlace.text = self.ownerData?.favPlace
                            self.goodCheckInVC.ownerUsername.text = self.ownerData?.username
                        
                            let userImage = self.imagesRef.child((self.ownerData?.profilePhotoShortKey)!)
                        
                            userImage.getData(maxSize: 1 * 1024 * 1024) { data, error in
                                if let _ = error {
                                    print(error!.localizedDescription)
                                } else {
                                    self.goodCheckInVC.ownerImage.image = UIImage(data: data!)
                                }
                            }
                        })
                    }
                }
                else {
                    self.goodCheckInVC.ownerUsername.text = "No Owner!"
                    self.goodCheckInVC.ownerFavPlace.text = "Check In to become the new owner!"
                    self.goodCheckInVC.ownerCheckInCount.text = ""
                }
                
                self.goodCheckInVC.metaPlaceUser = self.metaPlaceUser
            })
        }
    }
    
    func initLocationManager() {
        CLLocationManager.locationServicesEnabled()
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()
    }
    
    // Used to keep distance to target up to date
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Recomputing user location")
        let userLocation = locations.last!

        let dist = userLocation.distance(from: CLLocation(latitude: destPlace!.latitude, longitude: destPlace!.longitude))
        
        badCheckInVC.targetDistance.text = String(format: "%0.2f", dist) + " meters"
        
        if (dist < 500) {
            bottomHalfView.bringSubview(toFront: goodCheckInVC.view)
        }
        else {
            bottomHalfView.bringSubview(toFront: badCheckInVC.view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func buildFromStoryboard<T>(_ name: String) -> T {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let identifier = String(describing: T.self)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("Missing \(identifier) in Storyboard")
        }
        return viewController
    }
    

    // MARK: - Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "doCheckInSegue" {
            let destVC = segue.destination as? DoCheckInVC
            
            destVC?.checkInPlaceID = destPlace?.key
        }
    }
 */
}

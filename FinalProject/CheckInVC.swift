//
//  CheckInVC.swift
//  FinalProject
//
//  Created by AJ Fite on 5/20/18.
//  Copyright © 2018 AJ Fite. All rights reserved.
//

import UIKit
import CoreLocation

class CheckInVC: UIViewController, CLLocationManagerDelegate {
    
    var destPlace: Place?

    @IBOutlet weak var bottomHalfView: UIView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    
    private let topStackView = UIStackView()
    fileprivate lazy var goodCheckInVC: GoodCheckInVC = buildFromStoryboard("Main")
    fileprivate lazy var badCheckInVC: BadCheckInVC = buildFromStoryboard("Main")
    let locationManager = CLLocationManager()

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
        
        if (dist < 20) {
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

//
//  FirstViewController.swift
//  FinalProject
//
//  Created by AJ Fite on 5/19/18.
//  Copyright © 2018 AJ Fite. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase
import GeoFire
import CoreLocation

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var mapObject: MKMapView!
    var databasePlacesRef: DatabaseReference?
    var geoFire: GeoFire?
    var regionQuery: GFRegionQuery?
    let locationManager = CLLocationManager()
    let cscBuilding = CLLocationCoordinate2D(latitude: 35.300066, longitude: -120.662065)
    var annotations = [MKPointAnnotation]()
    
    var selectedPlace: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databasePlacesRef = Database.database().reference().child("places")
        geoFire = GeoFire(firebaseRef: Database.database().reference().child("geofire"))
        
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let newRegion = MKCoordinateRegion(center: cscBuilding, span: span)
        mapObject.setRegion(newRegion, animated: true)
        
        initLocationManager()
        //One time Init
        //initFirebase()
    }
    
    func initFirebase() {
        let newPlace = Place.init(name: "Baker Science", category: "Cool Building", latitude: 35.301366, longitude: -120.660441)
        let newPlaceRef = self.databasePlacesRef?.child(newPlace.key)
        newPlaceRef?.setValue(newPlace.toAnyObject())
        
        self.geoFire?.setLocation(CLLocation(latitude: newPlace.latitude, longitude: newPlace.longitude), forKey: newPlace.key)
        
    }
    
    func updateRegionQuery() {
        if let oldQuery = regionQuery {
            oldQuery.removeAllObservers()
        }
        
        regionQuery = geoFire?.query(with: mapObject.region)
        
        regionQuery?.observe(.keyEntered, with: { (key, location) in
            self.databasePlacesRef?.queryOrderedByKey().queryEqual(toValue: key).observe(.value, with: {snapshot in
                
                let newPlace = Place(key: key, snapshot: snapshot)
                self.addPlace(newPlace)
            })
        })
    }
    
    func addPlace(_ place: Place) {
        DispatchQueue.main.async {
            self.mapObject.addAnnotation(place)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is Place {
            let annotationView = MKPinAnnotationView()
            annotationView.pinTintColor = .red
            annotationView.annotation = annotation
            annotationView.canShowCallout = true
            annotationView.animatesDrop = true
            
            let discButton = UIButton(type: .detailDisclosure)
            
            annotationView.rightCalloutAccessoryView = discButton
            
            return annotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapView.removeAnnotations(mapView.annotations)
        
        updateRegionQuery()
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        selectedPlace = (view.annotation as! Place)
        performSegue(withIdentifier: "checkInSegue", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initLocationManager() {
        CLLocationManager.locationServicesEnabled()
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("didUpdate")
        let mostRecent = locations.last!
        
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = mostRecent.coordinate
        
        annotations.append(newAnnotation)
        
        if UIApplication.shared.applicationState == .active {
            mapObject.showAnnotations(annotations, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "checkInSegue") {
            let vc = segue.destination as! CheckInVC
            vc.destPlace = selectedPlace
        }
    }
}


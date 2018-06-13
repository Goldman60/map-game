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
    var annotations = [MKPointAnnotation]()
    
    var selectedPlace: Place?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databasePlacesRef = Database.database().reference().child("places")
        geoFire = GeoFire(firebaseRef: Database.database().reference().child("geofire"))
        
        initLocationManager()
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let newRegion = MKCoordinateRegion(center: (locationManager.location?.coordinate)!, span: span)
        mapObject.setRegion(newRegion, animated: true)
        
        //One time Init
        //THIS IS SLOW
        //initFirebase()
    }
    
    func updateRegionQuery() {
        print("region updated")
        if let oldQuery = regionQuery {
            oldQuery.removeAllObservers()
        }
        
        regionQuery = geoFire?.query(with: mapObject.region)
        
        regionQuery?.observe(.keyEntered, with: { (key, location) in
            self.databasePlacesRef?.queryOrderedByKey().queryEqual(toValue: key).observe(.value, with: {snapshot in
                
                print("Adding new place")
                
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
        let center = CLLocationCoordinate2D(latitude: mostRecent.coordinate.latitude, longitude: mostRecent.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = mostRecent.coordinate
        
        annotations.append(newAnnotation)
        
        if UIApplication.shared.applicationState == .active {
            mapObject.showAnnotations(annotations, animated: true)
            mapObject.setRegion(region, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "checkInSegue") {
            let vc = segue.destination as! CheckInVC
            vc.destPlace = selectedPlace
        }
    }
    
    // -- MARK: Init firebase stuff
    
    let jsonString = "https://projects.ajfite.com/csc436-finalproject/basedata.json"
    // This is a hastily converted XML file so it looks pretty bad
    
    //WARNING: This file is enormous and takes **MINUTES** to parse in the simulator
    func initFirebase() {
        print("Init firebase")
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let request = URLRequest(url: URL(string: jsonString)!)
        
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: filterAndStoreData)
        
        task.resume()
    }
    
    func filterAndStoreData(_ receivedData: Data?, _ response: URLResponse?, _ error: Error?) -> Void {
        
        if let data = receivedData {
            do {
                let decoder = JSONDecoder()
                let nodeBase = try decoder.decode(NodeBase.self, from: data)
                
                var elevation = 0
                var name = String()
                var cat = String()
                
                for node in nodeBase.nodes {
                    print("Loading Item")
                    
                    for keyVal in node.tags {
                        let key = keyVal.attributes.key
                        
                        if (key == "elev") {
                            elevation = Int(keyVal.attributes.value)!
                        }
                        else if (key == "name") {
                            name = keyVal.attributes.value
                        }
                        else if (key == "amenity" || key == "natural") {
                            cat = "\(keyVal.attributes.key): \(keyVal.attributes.value)"
                        }
                    }
                    
                    
                    let place = Place(name: name, category: cat, elevation: elevation, latitude: Double(node.attributes.lat)!, longitude: Double(node.attributes.lon)!, key: node.attributes.id)
                    
                    let newPlaceRef = self.databasePlacesRef?.child(place.key)
                    newPlaceRef?.setValue(place.toAnyObject())
                    
                    self.geoFire?.setLocation(CLLocation(latitude: place.latitude, longitude: place.longitude), forKey: place.key)
                }
            }
            catch {
                print("Decode Exception: \(error)")
            }
        }
    }
}


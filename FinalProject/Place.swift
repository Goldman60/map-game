//
//  Place.swift
//  FinalProject
//
//  Created by AJ Fite on 5/20/18.
//  Copyright © 2018 AJ Fite. All rights reserved.
//

import Foundation
import FirebaseDatabase
import MapKit

class Place: NSObject, MKAnnotation, Codable {
    let ref: DatabaseReference?
    var key: String
    
    var name: String
    var category: String
    var latitude: Double
    var longitude: Double
    var elevation: Int
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return category
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try values.decode(String.self, forKey: .name)
        elevation = try values.decode(Int.self, forKey: .elevation)
        category = try values.decode(String.self, forKey: .category)
        latitude = try values.decode(Double.self, forKey: .latitude)
        longitude = try values.decode(Double.self, forKey: .longitude)
        key = try values.decode(String.self, forKey: .key)
        ref = nil
    }
    
    enum CodingKeys : String, CodingKey {
        case name
        case category
        case latitude
        case longitude
        case elevation
        case key
    }
    
    init(name: String, category: String, elevation: Int, latitude: Double, longitude: Double, key: String) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.category = category
        self.elevation = elevation
        self.key = key
        self.ref = nil
        
        super.init()
    }
    
    init(key: String, snapshot: DataSnapshot) {
        let snaptemp = snapshot.value as! [String : AnyObject]
        let snapvalues = snaptemp[key] as! [String : AnyObject]
        name = snapvalues["name"] as? String ?? "Data Error"
        category = snapvalues["category"] as? String ?? "None"
        latitude = snapvalues["latitude"] as? Double ?? 0.0
        longitude = snapvalues["longitude"] as? Double ?? 0.0
        elevation = snapvalues["elevation"] as? Int ?? 0
        self.key = key
        ref = snapshot.ref

        super.init()
    }
    
    func toAnyObject() -> Any {
        return [
            "name" : name,
            "key" : key,
            "category" : category,
            "elevation" : elevation,
            "latitude" : latitude,
            "longitude" : longitude,
        ]
    }
}

//
//  MetaPlaceUser.swift
//  FinalProject
//
//  Created by AJ Fite on 6/12/18.
//  Copyright © 2018 AJ Fite. All rights reserved.
//

import Foundation
import Firebase

class MetaPlaceUser: Codable {
    var dateFromFirebase: String
    var checkInCount: Int
    
    let ref: DatabaseReference?
    var key: String
    
    static var dateFormatString: String = "yyyyMMddHHmm"
    
    var lastCheckIn: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = MetaPlaceUser.dateFormatString
        
        return dateFormatter.date(from: dateFromFirebase)
    }
    
    init(key: String, snapshot: DataSnapshot) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = MetaPlaceUser.dateFormatString
        
        let snaptemp = snapshot.value as! [String : AnyObject]
        let snapvalues = snaptemp[key] as! [String : AnyObject]
       
        dateFromFirebase = snapvalues["lastCheckIn"] as? String ?? dateFormatter.string(from: Date.distantPast)
        checkInCount = snapvalues["checkInCount"] as? Int ?? 0

        self.key = key
        ref = snapshot.ref
    }
    
    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = MetaPlaceUser.dateFormatString
        
        dateFromFirebase = dateFormatter.string(from: Date.distantPast)
        checkInCount = 0
        key = ""
        ref = nil
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        checkInCount = try values.decode(Int.self, forKey: .checkInCount)
        dateFromFirebase = try values.decode(String.self, forKey: .dateFromFirebase)
        key = try values.decode(String.self, forKey: .key)
        ref = nil
    }
    
    enum CodingKeys : String, CodingKey {
        case checkInCount
        case dateFromFirebase = "lastCheckIn"
        case key
    }
    
    func toAnyObject() -> Any {
        return [
            "checkInCount" : checkInCount,
            "lastCheckIn" : dateFromFirebase,
        ]
    }
}

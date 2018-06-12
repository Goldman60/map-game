//
//  UserData.swift
//  FinalProject
//
//  Created by AJ Fite on 5/20/18.
//  Copyright © 2018 AJ Fite. All rights reserved.
//

import Foundation
import FirebaseDatabase

class PublicUserData: Codable {
    var checkInCount: Int
    var username: String
    var favPlace: String
    var profilePhotoKey: String
    
    var profileImage: UIImage? {
        print("start image download")
        
        guard let url = URL(string: profilePhotoKey) else {
            return nil
        }
        
        guard let responseData = try? Data(contentsOf: url) else {
            return nil
        }
        
        print("Try image")
        
        let downloadedImage = UIImage(data: responseData)
        
        return downloadedImage
    }
    
    var profilePhotoTitle: String {
        return self.key
    }
    
    let ref: DatabaseReference?
    var key: String
    
    enum CodingKeys : String, CodingKey {
        case checkInCount
        case username
        case favPlace
        case key
        case profilePhotoKey
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        checkInCount = try values.decode(Int.self, forKey: .checkInCount)
        username = try values.decode(String.self, forKey: .username)
        favPlace = try values.decode(String.self, forKey: .favPlace)
        key = try values.decode(String.self, forKey: .key)
        profilePhotoKey = try values.decode(String.self, forKey: .profilePhotoKey)
        ref = nil
    }
    
    init(key: String, snapshot: DataSnapshot) {
        let snaptemp = snapshot.value as! [String : AnyObject]
        let snapvalues = snaptemp[key] as! [String : AnyObject]
        username = snapvalues["username"] as? String ?? "Anonymous User"
        favPlace = snapvalues["favPlace"] as? String ?? "No Favorite Place Set"
        checkInCount = snapvalues["checkInCount"] as? Int ?? 0
        profilePhotoKey = snapvalues["profilePhotoKey"] as? String ?? ""
        self.key = key
        ref = snapshot.ref
    }
    
    init(key: String) {
        checkInCount = 0
        username = ""
        favPlace = ""
        profilePhotoKey = ""
        self.key = key
        ref = nil
    }
    
    init() {
        checkInCount = 0
        username = ""
        favPlace = ""
        key = ""
        profilePhotoKey = ""
        ref = nil
    }
    
    func toAnyObject() -> Any {
        return [
            "username" : username,
            "favPlace" : favPlace,
            "checkInCount" : checkInCount,
            "profilePhotoKey" : profilePhotoKey,
        ]
    }
}

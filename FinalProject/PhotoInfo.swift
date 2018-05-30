//
//  PhotoInfo.swift
//  FirebaseDataStorage
//
//  Created by R on 3/4/18.
//  Copyright © 2018 R. All rights reserved.
//

import Foundation

class PhotoInfo {
    
    var title : String
    var photoKey = ""
    
    init(title : String) {
        self.title = title
    }
    
    func toAny() -> Any {
        return [
            "title" : title,
            "photoKey" : photoKey
        ]
    }
}

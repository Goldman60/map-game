//
//  xmlmodel.swift
//  FinalProject
//
//  Created by AJ Fite on 6/6/18.
//  Copyright © 2018 AJ Fite. All rights reserved.
//

// This file is used exclusively for the inital
// XML download of the open street maps data
// See the readme for more information

import Foundation

struct NodeBase: Codable {
    var nodes: [Node]
    
    enum CodingKeys: String, CodingKey {
        case nodes = "node"
    }
}

// Represents an OSM node, for conversion to a "place"
struct Node: Codable {
    var attributes: BaseAttributes
    var tags: [Tag]
    
    enum CodingKeys: String, CodingKey {
        case attributes = "@attributes"
        case tags = "tag"
    }
}

struct BaseAttributes: Codable {
    var id: String
    var lat: String
    var lon: String
}

struct Tag: Codable {
    var attributes: TagAttributes
    
    enum CodingKeys: String, CodingKey {
        case attributes = "@attributes"
    }
}

struct TagAttributes: Codable {
    var key: String
    var value: String
    
    enum CodingKeys: String, CodingKey {
        case key = "k"
        case value = "v"
    }
}

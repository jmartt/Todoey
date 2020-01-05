//
//  Item.swift
//  Todoey
//
//  Created by Jimmy Martini on 1/5/20.
//  Copyright © 2020 Jimmy Martini. All rights reserved.
//

import Foundation

// For a class to be encodable, it must only contain general data types
// "Codable" is an interface that contains both Encodable and Decodable interfaces so you don't have to type both every time you want to encode/decode something.
class Item: Codable { // class objects are now able to encode themselves into plist or json
    var title : String = ""
    var done : Bool = false
}

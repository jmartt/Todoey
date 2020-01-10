//
//  Category.swift
//  Todoey
//
//  Created by Jimmy Martini on 1/6/20.
//  Copyright © 2020 Jimmy Martini. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let items = List<Item>() // defines the forward relationship between Category and Items
}

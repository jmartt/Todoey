//
//  Item.swift
//  Todoey
//
//  Created by Jimmy Martini on 1/6/20.
//  Copyright © 2020 Jimmy Martini. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items") // Data Model - sets up the backwards relationship that every item has a parent category
}

//
//  Item.swift
//  Todoey
//
//  Created by Matthew Braden on 2019-07-18.
//  Copyright © 2019 Matthew Braden. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}

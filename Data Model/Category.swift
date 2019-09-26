//
//  Category.swift
//  Todoey
//
//  Created by Matthew Braden on 2019-07-18.
//  Copyright © 2019 Matthew Braden. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String = ""
    @objc dynamic var color : String = ""
    let items = List<Item>()
}

//
//  AppDelegate.swift
//  Todoey
//
//  Created by Matthew Braden on 2019-07-11.
//  Copyright © 2019 Matthew Braden. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        do {
            _ = try Realm()
        }
        catch {
            print("Error \(error)")
        }
        
        return true
    }
}


//
//  AppDelegate.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 06/02/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import RocksideWalletSdk

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var rockside: Rockside?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
            self.rockside = Rockside(token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJvcmlnaW4iOiJmci5zbWFydGZyb2cuZnIuU21hcnRXYWxsZXQiLCJjdXN0b21lcl9pZCI6IjEiLCJlbmRfdXNlcl9pZCI6IndhbGxldCIsImNvbnRyYWN0cyI6WyIweGY4NDViMjUwMUE2OWVGNDgwYUM1NzdiOTllOTY3OTZjMkI2QUU4OEUiLCIweDJjNjhiZkJjNkYyMjc0RTcwMTFDZDRBQjhENWMwZTY5QjIzNDEzMDkiLCIweEY5MkMxYWQ3NTAwNUU2NDM2QjRFRTg0ZTg4Y0IyM0VkOEEyOTA5ODgiLCIweDZiMTc1NDc0ZTg5MDk0YzQ0ZGE5OGI5NTRlZWRlYWM0OTUyNzFkMGYiLCIweDQ5M2M1N2M0NzYzOTMyMzE1YTMyODI2OWUxYWRhZDA5NjUzYjkwODEiXX0.9I9x0gw83WLuiiOw0AwhPASQxnHv0Lu84SdYz4ZZd80", chain:.mainnet)
        
        /*self.rockside = Rockside(token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJvcmlnaW4iOiJmci5zbWFydGZyb2cuZnIuU21hcnRXYWxsZXQiLCJjdXN0b21lcl9pZCI6IjIiLCJlbmRfdXNlcl9pZCI6InRvb3QiLCJjb250cmFjdHMiOlsiMHhmODQ1YjI1MDFBNjllRjQ4MGFDNTc3Yjk5ZTk2Nzk2YzJCNkFFODhFIiwiMHgyYzY4YmZCYzZGMjI3NEU3MDExQ2Q0QUI4RDVjMGU2OUIyMzQxMzA5IiwiMHhGOTJDMWFkNzUwMDVFNjQzNkI0RUU4NGU4OGNCMjNFZDhBMjkwOTg4Il19.bnlL93mmZ9OBwgmxuUyefAMcbVtkL1F_oOcIURAnEg8", chain:.mainnet)
        
        self.rockside?.rocksideUrl = "https://api-staging.rockside.io"*/
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


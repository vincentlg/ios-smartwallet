//
//  AppDelegate.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 06/02/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import RocksideWalletSdk
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var rockside: Rockside?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        self.rockside = Rockside(token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJvcmlnaW4iOiJpby5yb2Nrc2lkZS5zbWFydHdhbGxldCIsImN1c3RvbWVyX2lkIjoiMSIsImVuZF91c2VyX2lkIjoid2FsbGV0IiwiY29udHJhY3RzIjpbIjB4Zjg0NWIyNTAxQTY5ZUY0ODBhQzU3N2I5OWU5Njc5NmMyQjZBRTg4RSIsIjB4MmM2OGJmQmM2RjIyNzRFNzAxMUNkNEFCOEQ1YzBlNjlCMjM0MTMwOSIsIjB4RjkyQzFhZDc1MDA1RTY0MzZCNEVFODRlODhjQjIzRWQ4QTI5MDk4OCIsIjB4NmIxNzU0NzRlODkwOTRjNDRkYTk4Yjk1NGVlZGVhYzQ5NTI3MWQwZiIsIjB4NDkzYzU3YzQ3NjM5MzIzMTVhMzI4MjY5ZTFhZGFkMDk2NTNiOTA4MSJdfQ.mlJBCgB2Zh6YncWl9Y0tQkoGSjx9rYz7crfDA0MAEA0", chain:.ropsten)
              

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


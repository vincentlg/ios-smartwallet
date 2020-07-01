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
        self.rockside = Rockside(token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJvcmlnaW4iOiJpby5yb2Nrc2lkZS5tb29ua2V5IiwiY3VzdG9tZXJfaWQiOiI0IiwiZW5kX3VzZXJfaWQiOiJ3YWxsZXQiLCJjb250cmFjdHMiOlsiMHg4Njk2OWQyOUY1ZmQzMjdFMTAwOWJBNjYwNzJCRTIyREI2MDE3Y0M2Il19.t4qrbmZCfS0y4yR3AdegURBtBaZ4CSiyjSFpVftvJZk", chain:.mainnet, forwarder: "0x4caf1b35903b775fc0c330a7060f1c1b63dfcd2f" )
              

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


//
//  ConnectViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 07/04/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import LocalAuthentication

class ConnectViewController: UIViewController {
    
    @IBAction func connectAction(_ sender: Any) {
        self.connect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.connect()
    }
    
    public func connect() {
        let context = LAContext()
        context.localizedCancelTitle = ""
        
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Log in to your account"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in

                if success {
                    DispatchQueue.main.async {
                        self.navigationController?.displayWalletView()
                    }
                }
            }
        } else {
            self.navigationController?.displayWalletView()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

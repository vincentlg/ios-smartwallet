//
//  WalletNavigationViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 23/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit

class WalletNavigationViewController: UINavigationController {
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TODO DEBUG
        //try? self.rockside.clearIdentity()
      
        if (try? self.rockside.retrieveIdentity()) != nil {
            self.displayWalletView()
        } else {
            self.displayNoWalletView()
        }
    }
    
    func displayWalletView(animated: Bool = false, newWallet: Bool = false) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
        vc.isNewWallet = newWallet
        self.setViewControllers([vc], animated: animated)
    }
    
    func displayNoWalletView(animated: Bool = false) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WithoutWalletViewController") as! WithoutWalletViewController
        self.setViewControllers([vc], animated: animated)
    }
    
    func displayConnectView() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConnectViewController") as! ConnectViewController
        self.setViewControllers([vc], animated: false)
    }
    
}

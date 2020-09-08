//
//  WalletNavigationViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 23/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit


class WalletNavigationViewController: UINavigationController {
    
    let walletStorage: WalletStorage = WalletStorage()
    
    let walletViewController =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        guard let walletId = try? self.walletStorage.retrieve() else {
            self.displayNoWalletView()
            return
        }
      
        Application.restore(walletId: walletId)
        
        self.displayWalletView()
        
    }
    
    func displayWalletView(animated: Bool = false, newWallet: Bool = false) {
        walletViewController.isNewWallet = newWallet
        self.setViewControllers([walletViewController], animated: animated)
    }
    
    func displayNoWalletView(animated: Bool = false) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WithoutWalletViewController") as! WithoutWalletViewController
        self.setViewControllers([vc], animated: animated)
    }
    
    func displayConnectView() {
        self.dismiss(animated: false, completion: nil)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConnectViewController") as! ConnectViewController
        self.setViewControllers([vc], animated: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
}

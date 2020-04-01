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
        
        let vc:UIViewController
        
        if (try? self.rockside.retrieveIdentity()) != nil {
            
            vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
                  
            
        } else {
            vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WithoutWalletViewController") as! WithoutWalletViewController
        }
        
        self.setViewControllers([vc], animated: false)
    }
    
}

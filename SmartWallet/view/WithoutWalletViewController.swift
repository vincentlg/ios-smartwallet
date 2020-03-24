//
//  WithoutWalletViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 06/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit

class WithoutWalletViewController: UIViewController {
    
    
    @IBAction func createWalletAction(_ sender: Any) {
        self.rockside.createIdentity() { (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    try? self.rockside.storeIdentity()
                    self.performSegue(withIdentifier: "show-recovery-segue", sender: self)
                }
                
                break
            case .failure(let error):
                print("error")
                print(error)
                break
            }
        }
    }
}

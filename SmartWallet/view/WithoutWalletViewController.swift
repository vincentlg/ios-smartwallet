//
//  WithoutWalletViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 06/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import JGProgressHUD
import MaterialComponents.MaterialSnackbar

class WithoutWalletViewController: UIViewController {
    
    
    @IBAction func createWalletAction(_ sender: Any) {
        
        let hud = JGProgressHUD(style: .extraLight)
        hud.textLabel.text = "Your wallet is being created.\nPlease wait (around 1 min)"
        hud.show(in: self.view)
        
        
        self.rockside.createIdentity() { (result) in
            switch result {
            case .success(let txHash):
                DispatchQueue.main.async {
                   
                    
                    _ = self.rockside.rpc.waitTxToBeMined(txHash: txHash) { (result) in
                        switch result {
                        case .success(_):
                            DispatchQueue.main.async {
                                hud.dismiss()
                                try? self.rockside.storeIdentity()
                                self.performSegue(withIdentifier: "show-recovery-segue", sender: self)
                            }
                            break
                            
                        case .failure(let error):
                            print(error)
                            DispatchQueue.main.async {
                                hud.dismiss()
                                self.displayErrorOccured()
                            }
                            break
                        }
                    }
                    
                    
                }
                
                break
            case .failure(let error):
                print(error)
                hud.dismiss()
                self.displayErrorOccured()
                break
            }
        }
    }
    
    public func displayErrorOccured() {
        let snackBarMessage = MDCSnackbarMessage()
        snackBarMessage.text = "An error occured. Please try again."
        MDCSnackbarManager.show(snackBarMessage)
    }
}

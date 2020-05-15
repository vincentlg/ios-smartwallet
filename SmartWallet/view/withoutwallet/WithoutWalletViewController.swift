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
            case .success(let deployIdentityResponse):
                DispatchQueue.main.async {
                   
                    
                    _ = self.rockside.waitTxToBeMined(trackingID: deployIdentityResponse.tracking_id) { (result) in
                        switch result {
                        case .success(_):
                            DispatchQueue.main.async {
                                hud.dismiss()
                                try? self.rockside.storeIdentity()
                                self.navigationController?.displayWalletView(animated: true, newWallet: true)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show-wallet-segue" {
            if let destinationVC = segue.destination as? WalletViewController {
                destinationVC.isNewWallet = true
            }
        }
    
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
       
}

//
//  SendViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 10/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import RocksideWalletSdk

class SendViewController: UIViewController {
    
    @IBOutlet weak var destinationTextField: UITextField!
    
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBAction func scanAddressAction(_ sender: Any) {
    }
    
    public func getReceipt(txHash: String) {
        
    }
    
    @IBAction func sendAction(_ sender: Any) {
        
        //TODO: Encapsulate in SDK
        let formatter = EtherNumberFormatter()
        let amount =  formatter.number(from: self.amountTextField.text!)
        let weiAmount = amount?.magnitude.serialize()
        
        self.rockside.relayTransaction(to: destinationTextField.text!, value: weiAmount!.hexValueNoLeadingZero, data: "" ) { (result) in
            switch result {
            case .success(let txHash):
                print("ICI "+txHash)
                DispatchQueue.main.async {
        
                    if let walletViewController = (self.presentingViewController as? UINavigationController)?.topViewController as? WalletViewController{
                        walletViewController.watchTx(txHash: txHash)
                    }
                    self.dismiss(animated: true, completion: nil)
                }
                break
                
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
                break
            }
        }
    }
}

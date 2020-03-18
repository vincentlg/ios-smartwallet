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
    
    @IBAction func sendAction(_ sender: Any) {
        
        //TODO: Encapsulate in SDK
        let formatter = EtherNumberFormatter()
        let amount =  formatter.number(from: self.amountTextField.text!)
        let weiAmount = amount?.magnitude.serialize()
       
        self.rockside.relayTransaction(to: destinationTextField.text!, value: weiAmount!.hexValueNoLeadingZero, data: "" ) { (result) in
            switch result {
            case .success(let txHash):
                 DispatchQueue.main.async {
                    //self.dismiss(animated: true, completion: nil)
                    print(txHash)
                    self.rockside.transactionReceipt(txHash: txHash) { (result) in
                    switch result {
                         case .success(let txReceipt):
                            print(txReceipt)
                        break
                            case .failure(let error):
                                print(error)
                                break
                            }
                        }
                }
                
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
}

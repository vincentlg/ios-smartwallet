//
//  ViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 06/02/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import RocksideWalletSdk

class WalletViewController: UIViewController {
    
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var transactionInProgressView: UIView!
    
    let walletTabViewController = WalletTabViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.transactionInProgressView.isHidden = true
        
        self.amountLabel.text = self.rockside.identity?.ethereumAddress
        walletTabViewController.view.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height)
        self.contentView.addSubview(walletTabViewController.view)
    }
    
    public func watchTx(txHash: String) {
        self.transactionInProgressView.isHidden = false
        _ = self.rockside.rpc.waitTxToBeMined(txHash: txHash) { (result) in
            switch result {
            case .success(let txReceipt):
                print (txReceipt)
                DispatchQueue.main.async {
                    self.transactionInProgressView.isHidden = true
                    self.walletTabViewController.retriveAllTransactions()
                }
                break
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self.transactionInProgressView.isHidden = true
                }
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "send-token-segue" {
               if let destinationVC = segue.destination as? SendViewController {
                  
                destinationVC.tokens = self.walletTabViewController.tokenBalanceArray()
                destinationVC.fromToken = destinationVC.tokens![0]
               }
           }
           
       }
    
    
    
    
}

//
//  ViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 06/02/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import RocksideWalletSdk
import Tabman

class WalletViewController: UIViewController {
    
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tabHeaderView: UIView!
    
    let walletTabViewController = WalletTabViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.contentView.addSubview(walletTabViewController.view)
        
        self.walletTabViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.walletTabViewController.balanceUpdatedHandler = self.updateBalance
        
        let bar = TMBarView<WalletTabLayout, TabButtonBar, TMBarIndicator.None>()
        bar.backgroundView.style = .clear
        bar.layout.transitionStyle = .snap
        bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        NSLayoutConstraint.activate([
            self.walletTabViewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            self.walletTabViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.walletTabViewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            self.walletTabViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        self.walletTabViewController.addBar(bar, dataSource: walletTabViewController, at: .custom(view: self.tabHeaderView, layout: nil))
    }
    
    private func updateBalance() {
        self.amountLabel.text = self.walletTabViewController.tokenBalances["ETH"]!.balance+" ETH"
    }
    
    public func watchTx(txHash: String) {
       // self.transactionInProgressView.isHidden = false
        _ = self.rockside.rpc.waitTxToBeMined(txHash: txHash) { (result) in
            switch result {
            case .success(let txReceipt):
                print (txReceipt)
                DispatchQueue.main.async {
                    //self.transactionInProgressView.isHidden = true
                    self.walletTabViewController.retriveAllTransactions()
                }
                break
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    //self.transactionInProgressView.isHidden = true
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
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

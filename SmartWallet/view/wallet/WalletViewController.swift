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
import MaterialComponents.MaterialSnackbar



typealias WatchTxHandler = (_: RelayResponse) -> Void
typealias DisplayErrorHandler = () -> Void

class WalletViewController: UIViewController {
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tabHeaderView: UIView!
    
    var moonkeyService = MoonkeyService()
    
    public var isNewWallet = false
    
    var snackBarMessage: MDCSnackbarMessage?
    
    let walletTabViewController = WalletTabViewController()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let snack = self.snackBarMessage {
            MDCSnackbarManager.show(snack)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contentView.addSubview(walletTabViewController.view)
        
        self.walletTabViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.walletTabViewController.balanceUpdatedHandler = self.updateBalance
        self.walletTabViewController.displayErrorHandler = self.displayErrorOccured
        
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
        
        if (self.isNewWallet) {
            self.isNewWallet = false
            self.performSegue(withIdentifier: "show-recovery-segue", sender: self)
        }
    }
    
    private func updateBalance() {
        self.amountLabel.text = self.walletTabViewController.tokenBalances["ETH"]!.formattedBalance
    }

    
    private func displayWaitingForTx(txHash: String) {
        self.snackBarMessage = MDCSnackbarMessage()
        self.snackBarMessage!.automaticallyDismisses = false
        self.snackBarMessage!.text = "Your transaction is being validated"
        
        let action = MDCSnackbarMessageAction()
        action.title = "See TX"
        
        let actionHandler = {() in
          UIApplication.shared.open(URL(string: "https://etherscan.io/tx/"+txHash)!, options: [:], completionHandler: nil)
        }
        action.handler = actionHandler
        
        self.snackBarMessage!.action = action
        MDCSnackbarManager.show(self.snackBarMessage)
    }
    
    public func displayErrorOccured() {
        self.snackBarMessage = MDCSnackbarMessage()
        self.snackBarMessage!.text = "An error occured"
        MDCSnackbarManager.show(self.snackBarMessage)
    }
    
    public func watchTx(relayResponse: RelayResponse) {
        
        self.displayWaitingForTx(txHash: relayResponse.transaction_hash)
        
    
        _ = self.moonkeyService.waitTxToBeMined(trackingID: relayResponse.tracking_id) { (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    MDCSnackbarManager.dismissAndCallCompletionBlocks(withCategory: nil)
                    self.snackBarMessage = nil
                    self.walletTabViewController.retriveAllTransactions()
                }
                break
            case .failure(let error):
                DispatchQueue.main.async {
                    MDCSnackbarManager.dismissAndCallCompletionBlocks(withCategory: nil)
                    self.snackBarMessage = nil
                }
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "send-token-segue" {
               if let destinationVC = segue.destination as? SendViewController {
                  
                destinationVC.watchTxHandler = self.watchTx
                destinationVC.displayErrorHandler = self.displayErrorOccured
                
                destinationVC.tokens = self.walletTabViewController.tokenBalanceArray()
                destinationVC.fromToken = destinationVC.tokens![0]
               }
           }
        
            if segue.identifier == "exchange-segue" {
                if let destinationVC = segue.destination as? ExchangeViewController {
                    
                    destinationVC.tokensBalance = self.walletTabViewController.tokenBalanceArray()
                    
                    destinationVC.watchTxHandler = self.watchTx
                    destinationVC.displayErrorHandler = self.displayErrorOccured
                }
            }
       }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

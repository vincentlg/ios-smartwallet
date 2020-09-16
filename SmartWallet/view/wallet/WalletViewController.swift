//
//  ViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 06/02/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit

import Tabman
import MaterialComponents.MaterialSnackbar
import BigInt



typealias WatchTxHandler = (_: RelayResponse) -> Void
typealias DisplayErrorHandler = () -> Void

class WalletViewController: UIViewController {
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tabHeaderView: UIView!

    var transactionInProgress: Bool = false
    
    var snackBarMessage: MDCSnackbarMessage?
    
    let formatter = EtherNumberFormatter()
    
    let walletTabViewController = WalletTabViewController()
    
    public var isNewWallet = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let snack = self.snackBarMessage {
           MDCSnackbarManager.default.show(snack)
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
        
        Application.updateEthPrice() { (result) in
            switch result {
            case .success(_), .failure(_):
                 DispatchQueue.main.async {
                    self.amountLabel.text = "$0"
                 }
                break
            }
        }
        
    }
    
    
    @IBAction func sendTouched(_ sender: Any) {
        
        if !self.transactionInProgress {
            self.performSegue(withIdentifier: "send-token-segue", sender: self)
        } else {
            self.displayTransactionInProgressAlert()
        }
    }
    
    @IBAction func exchangeTouched(_ sender: Any) {
        if !self.transactionInProgress {
            self.performSegue(withIdentifier: "exchange-segue", sender: self)
        } else {
            self.displayTransactionInProgressAlert()
        }
    }
    
    private func displayTransactionInProgressAlert() {
        let ac = UIAlertController(title: "Transaction in progress", message: "Wait until your transaction is mined before making a new transfer.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(ac, animated: true)
    }
    
    
    private func updateBalance() {
        self.amountLabel.text = self.calculateFiatValue()
    }
    
    private func calculateFiatValue() -> String {
        let balanceList = Array<TokenBalance>(self.walletTabViewController.tokenBalances.values)
        
        var value: Double = 0
        for tokenBalance in balanceList {
            let price: Double?
            if tokenBalance.symbol == "ETH"{
                price = Application.ethPrice
            } else {
                price = Application.tokenPrices?[tokenBalance.address]?["usd"]
            }
            
            value += tokenBalance.fiatValue(tokenPrice: price)
        }
        
        return "$"+String(format: "%.2f", value)
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
        MDCSnackbarManager.default.show(self.snackBarMessage)
    }
    
    public func displayErrorOccured() {
        self.snackBarMessage = MDCSnackbarMessage()
        self.snackBarMessage!.text = "An error occured"
        MDCSnackbarManager.default.show(self.snackBarMessage)
    }
    
    public func watchTx(relayResponse: RelayResponse) {
        
        self.transactionInProgress = true
        self.displayWaitingForTx(txHash: relayResponse.transaction_hash)
        
        
        _ = Application.backendService.waitTxToBeMined(trackingID: relayResponse.tracking_id) { (result) in
            switch result {
            case .success(_):
                self.transactionInProgress = false
                DispatchQueue.main.async {
                    MDCSnackbarManager.default.dismissAndCallCompletionBlocks(withCategory: nil)
                    self.snackBarMessage = nil
                    self.walletTabViewController.retriveAllTransactions()
                }
                break
            case .failure(_):
                self.transactionInProgress = false
                DispatchQueue.main.async {
                    MDCSnackbarManager.default.dismissAndCallCompletionBlocks(withCategory: nil)
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

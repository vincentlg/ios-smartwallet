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
    
    var tokens: [TokenBalance]?
    var fromToken: TokenBalance?
    
    var watchTxHandler: WatchTxHandler?
    var displayErrorHandler: DisplayErrorHandler?
    
    @IBOutlet weak var destinationTextField: UITextField!
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var tokenLabel: UILabel!
    
    @IBAction func selectTokenAction(_ sender: Any) {
    }
    
    @IBAction func scanAddressAction(_ sender: Any) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshView()
    }
    
    func refreshView() {
        self.tokenLabel.text = self.fromToken?.symbol
    }
    
    @IBAction func sendAction(_ sender: Any) {
        let formatter = EtherNumberFormatter()
        let amount =  formatter.number(from: self.amountTextField.text!)
        
        
        if (self.fromToken?.symbol == "ETH") {
            self.sendEth(amount: amount!.description)
        } else {
            self.sendERC20(amount: amount!.description)
        }
        
    }
    
    func sendERC20(amount: String) {
        self.rockside.identity!.erc20Transfer(ercAddress: fromToken!.address!, to: destinationTextField.text!, value: amount) { (result) in
            switch result {
            case .success(let txHash):
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: {
                        self.watchTxHandler?(txHash)
                    })
                }
                break
                
            case .failure(_):
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: {
                        self.displayErrorHandler?()
                    })
                }
                break
            }
        }
    }
    
    func sendEth(amount: String) {
        self.rockside.identity!.relayTransaction(to: destinationTextField.text!, value: amount, data: "" ) { (result) in
            switch result {
            case .success(let txHash):
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: {
                        self.watchTxHandler?(txHash)
                    })
                }
                break
                
            case .failure(_):
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: {
                        self.displayErrorHandler?()
                    })
                }
                break
            }
        }
    }
    
    public func selectToken(token: TokenBalance) {
        self.fromToken = token
        self.refreshView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "select-token-balance-segue" {
            if let destinationVC = segue.destination as? TokenBalanceTableViewController {
                destinationVC.tokens = self.tokens
                destinationVC.selectionHandler = self.selectToken
            }
        }
    }
}

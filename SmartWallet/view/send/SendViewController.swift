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
        
        //TODO: Encapsulate in SDK
        let formatter = EtherNumberFormatter()
        let amount =  formatter.number(from: self.amountTextField.text!)
        let weiAmount = amount?.magnitude.serialize()
        
        if (self.fromToken?.symbol == "ETH") {
            self.sendEth(amount: weiAmount!.hexValueNoLeadingZero)
        } else {
            self.sendERC20(amount: amount!.description)
        }
        
    }
    
    func sendERC20(amount: String) {
        self.rockside.erc20Transfer(ercAddress: fromToken!.address!, to: destinationTextField.text!, value: amount) { (result) in
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
    
    func sendEth(amount: String) {
        self.rockside.relayTransaction(to: destinationTextField.text!, value: amount, data: "" ) { (result) in
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
    
    public func selectToken(token: TokenBalance) {
        self.fromToken = token
        print(self.fromToken?.address)
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

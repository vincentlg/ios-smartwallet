//
//  SendViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 10/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import RocksideWalletSdk
import MaterialComponents.MaterialTextFields
import JGProgressHUD

class SendViewController: UIViewController {
    
    @IBOutlet weak var maxAmountLabel: UILabel!
    
    @IBOutlet weak var amountTextField: MDCTextField!
    var amountTextFieldController: MDCTextInputControllerUnderline?
    
    @IBOutlet weak var destinationTextField: MDCTextField!
    var destinationTextFieldController: MDCTextInputControllerUnderline?
      
    var tokens: [TokenBalance]?
    var fromToken: TokenBalance?
    
    var watchTxHandler: WatchTxHandler?
    var displayErrorHandler: DisplayErrorHandler?
    
    
    @IBOutlet weak var tokenLabel: UILabel!
    
    @IBAction func selectTokenAction(_ sender: Any) {
        self.performSegue(withIdentifier: "select-token-balance-segue", sender: self)
    }
    
    @IBAction func scanAddressAction(_ sender: Any) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.amountTextFieldController = MDCTextInputControllerUnderline(textInput: amountTextField)
        self.destinationTextFieldController = MDCTextInputControllerUnderline(textInput: destinationTextField)
        self.amountTextField.becomeFirstResponder()
        
        self.refreshView()
        
    }

    func refreshView() {
        self.tokenLabel.text = self.fromToken?.symbol
        self.maxAmountLabel.text = "Max: "+self.fromToken!.formattedAmout
    }
    
    @IBAction func sendAction(_ sender: Any) {
        let formatter = EtherNumberFormatter()
        
        self.amountTextFieldController?.setErrorText(nil, errorAccessibilityValue:nil)
        self.destinationTextFieldController?.setErrorText(nil, errorAccessibilityValue:nil)
        
        guard let amountText = self.amountTextField.text, let amount = formatter.number(from: amountText) else {
            self.amountTextFieldController?.setErrorText("Amount invaid", errorAccessibilityValue: "Amount invaid")
            return
        }
        
        if amount.description.description == "0" {
            self.amountTextFieldController?.setErrorText("Amount invaid", errorAccessibilityValue: "Amount invaid")
            return
        }
        
        if amount > fromToken!.balance! {
            self.amountTextFieldController?.setErrorText("Insuffisant balance", errorAccessibilityValue: "Insuffisant balance")
            return
        }
        
        if  !EthereumAddress.isValid(string: destinationTextField.text!) {
            self.destinationTextFieldController?.setErrorText("Invalid address", errorAccessibilityValue: "Invalid addresss")
            return
        }
            
        if (self.fromToken?.symbol == "ETH") {
            self.sendEth(amount: amount.description)
        } else {
            self.sendERC20(amount: amount.description)
        }
    }
    
    func sendERC20(amount: String) {
        
        let hud = JGProgressHUD(style: .dark)
        hud.show(in: self.view)
        
        self.rockside.identity!.erc20Transfer(ercAddress: fromToken!.address!, to: destinationTextField.text!, value: amount) { (result) in
            switch result {
            case .success(let txHash):
                DispatchQueue.main.async {
                    hud.dismiss()
                    self.dismiss(animated: true, completion: {
                        self.watchTxHandler?(txHash)
                    })
                }
                break
                
            case .failure(_):
                DispatchQueue.main.async {
                    hud.dismiss()
                    self.dismiss(animated: true, completion: {
                        self.displayErrorHandler?()
                    })
                }
                break
            }
        }
    }
    
    func sendEth(amount: String) {
        let hud = JGProgressHUD(style: .dark)
        hud.show(in: self.view)
              
        self.rockside.identity!.relayTransaction(to: destinationTextField.text!, value: amount) { (result) in
            switch result {
            case .success(let txHash):
                DispatchQueue.main.async {
                    hud.dismiss()
                    self.dismiss(animated: true, completion: {
                        self.watchTxHandler?(txHash)
                    })
                }
                break
                
            case .failure(_):
                DispatchQueue.main.async {
                    hud.dismiss()
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
            if let destinationVC = segue.destination as? TokensSelectionViewController {
                destinationVC.tokens = self.tokens
                destinationVC.selectionHandler = self.selectToken
            }
        }
    }
}

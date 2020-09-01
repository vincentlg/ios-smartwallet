//
//  SendViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 10/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit

import MaterialComponents.MaterialTextFields
import JGProgressHUD
import BigInt
import web3

class SendViewController: UIViewController {
    
    @IBOutlet weak var maxAmountLabel: UILabel!
    
    @IBOutlet weak var amountTextField: MDCTextField!
    var amountTextFieldController: MDCTextInputControllerUnderline?
    
    @IBOutlet weak var destinationTextField: MDCTextField!
    var destinationTextFieldController: MDCTextInputControllerUnderline?
    
    @IBOutlet weak var gasFeesLabels: UILabel!
    
    
    var tokens: [TokenBalance]?
    var fromToken: TokenBalance?
    
    var watchTxHandler: WatchTxHandler?
    var displayErrorHandler: DisplayErrorHandler?
    
    
    var moonkeyService: MoonkeyService = MoonkeyService()
    
    @IBOutlet weak var tokenLabel: UILabel!
    
    @IBAction func selectTokenAction(_ sender: Any) {
        self.performSegue(withIdentifier: "select-token-balance-segue", sender: self)
    }
    
    @IBAction func scanAddressAction(_ sender: Any) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.amountTextFieldController = MDCTextInputControllerUnderline(textInput: amountTextField)
        self.amountTextField.clearButtonMode = .never
        self.destinationTextFieldController = MDCTextInputControllerUnderline(textInput: destinationTextField)
        self.amountTextField.becomeFirstResponder()
        
        let hud = JGProgressHUD(style: .dark)
        hud.show(in: self.view)
        Application.updateEthPrice() { (result) in
            switch result {
            case .failure(_), .success(_):
                DispatchQueue.main.async {
                    hud.dismiss()
                    self.refreshView()
                }
                break
            }
        }
        
    }
    
    func refreshView() {
        self.tokenLabel.text = self.fromToken?.symbol
        self.maxAmountLabel.text = "Max: "+self.fromToken!.formattedBalance()
        
        var safeTxGas =  BigUInt(10000)
        if fromToken?.symbol != "ETH" {
            safeTxGas =  BigUInt(20000)
        }
        
        Application.calculateGasFees(safeGas: safeTxGas) { (result) in
            switch result {
            case .success(let fees):
                DispatchQueue.main.async {
                    self.gasFeesLabels.text = fees
                }
                return
            case .failure(_):
                self.gasFeesLabels.text = "error"
                return
            }
            
        }
    }
    
    @IBAction func sendAction(_ sender: Any) {
        let formatter = EtherNumberFormatter()
        
        self.amountTextFieldController?.setErrorText(nil, errorAccessibilityValue:nil)
        self.destinationTextFieldController?.setErrorText(nil, errorAccessibilityValue:nil)
        
        guard let amountText = self.amountTextField.text, let amount = formatter.number(from: amountText) else {
            self.amountTextFieldController?.setErrorText("Amount invalid", errorAccessibilityValue: "Amount invalid")
            return
        }
        
        if amount.description.description == "0" {
            self.amountTextFieldController?.setErrorText("Amount invalid", errorAccessibilityValue: "Amount invalid")
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
        self.view.endEditing(true)
        
        var to = web3.EthereumAddress(self.destinationTextField.text!)
        var data = Data()
        var value = BigUInt(amount)
        var safeTxGas =  BigUInt(10000)
        
        if (self.fromToken?.symbol != "ETH") {
            value = BigUInt(0)
            to = web3.EthereumAddress(self.fromToken!.address)
            data = ERC20Encoder.encodeTransfer(to: EthereumAddress(string: destinationTextField.text!)!, tokens: BigUInt(amount))
            
            safeTxGas = BigUInt(20000)
        }
        
        let hud = JGProgressHUD(style: .dark)
        hud.show(in: self.view)
        
        Application.relay(to: to, value: value,data: data, safeTxGas: safeTxGas) { (result) in
            switch result {
            case .success(let txResponse):
                
                DispatchQueue.main.async {
                    hud.dismiss()
                    self.dismiss(animated: true, completion: {
                        self.watchTxHandler?(txResponse)
                    })
                }
                break;
                
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
    
    func qrCodeFound(qrcode: String) {
        let address = qrcode.replacingOccurrences(of: "ethereum:", with: "")
        self.destinationTextField.text = address
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "select-token-balance-segue" {
            if let destinationVC = segue.destination as? TokensSelectionViewController {
                destinationVC.tokens = self.tokens
                destinationVC.selectionHandler = self.selectToken
            }
        }
        
        if segue.identifier == "scan_qrcode_segue" {
            if let destinationVC = segue.destination as? ScannerViewController {
                destinationVC.qrCodeHandler = self.qrCodeFound
            }
        }
    }
}

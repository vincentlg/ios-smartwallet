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
import BigInt

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
        
        if self.tokens![0].balance! < BigInt(700000000000000)  {
            self.amountTextFieldController?.setErrorText("Need more ETH for gas", errorAccessibilityValue: "Need more ETH for gas")
                 return
        }
        
        if  !EthereumAddress.isValid(string: destinationTextField.text!) {
            self.destinationTextFieldController?.setErrorText("Invalid address", errorAccessibilityValue: "Invalid addresss")
            return
        }
        self.view.endEditing(true)
        
        if (self.fromToken?.symbol == "ETH") {
            self.sendEth(amount: BigUInt(amount))
        } else {
            self.sendERC20(amount: BigUInt(amount))
        }
    }
    
    func sendERC20(amount: BigUInt) {
        
        let hud = JGProgressHUD(style: .dark)
        hud.show(in: self.view)
        let ercTransferData = ERC20Encoder.encodeTransfer(to: EthereumAddress(string: destinationTextField.text!)!, tokens: amount).hexValue
        let messageData = Identity.current!.encodeExecute(to: fromToken!.address!, value:"0", data: Data(hexString:ercTransferData)!)
        
        moonkeyService.relayTransaction(identity: Identity.current!, messageData: messageData, gas:"150000") { (result) in
           switch result {
                      case .success(let txResponse):
                          DispatchQueue.main.async {
                              hud.dismiss()
                              self.dismiss(animated: true, completion: {
                                  self.watchTxHandler?(txResponse)
                              })
                          }
                          break
                          
                      case .failure(let error):
                          NSLog(error.localizedDescription)
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
    
    func sendEth(amount: BigUInt) {
        let hud = JGProgressHUD(style: .dark)
        hud.show(in: self.view)
              
        let messageData = Identity.current!.encodeExecute(to: destinationTextField.text!, value:amount, data: Data())
        moonkeyService.relayTransaction(identity: Identity.current!, messageData: messageData, gas: "100000") { (result) in
            switch result {
                       case .success(let txResponse):
                           DispatchQueue.main.async {
                               hud.dismiss()
                               self.dismiss(animated: true, completion: {
                                   self.watchTxHandler?(txResponse)
                               })
                           }
                           break
                           
                       case .failure(let error):
                           NSLog(error.localizedDescription)
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
        self.destinationTextField.text = qrcode
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

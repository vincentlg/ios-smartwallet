//
//  RestoreViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 16/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit

import MaterialComponents.MaterialTextFields


class RestoreViewController: UIViewController {
    
    let walletStorage: WalletStorage = WalletStorage()
    
    let rpc: RpcClient = RpcClient()
    
    @IBOutlet weak var walletAddressTextField: MDCTextField!
    var walletAddressTextFieldController: MDCTextInputControllerUnderline?
    
    @IBOutlet weak var twelvesWordsView: MDCTextField!
     var twelvesWordsViewController: MDCTextInputControllerUnderline?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.walletAddressTextFieldController = MDCTextInputControllerUnderline(textInput: self.walletAddressTextField)
        self.twelvesWordsViewController = MDCTextInputControllerUnderline(textInput: self.twelvesWordsView)
        
        self.walletAddressTextField.becomeFirstResponder()
    }
    
    
    @IBAction func RestoreAction(_ sender: Any) {
        
        self.walletAddressTextFieldController?.setErrorText(nil, errorAccessibilityValue:nil)
        self.twelvesWordsViewController?.setErrorText(nil, errorAccessibilityValue:nil)
        
        
        if  !EthereumAddress.isValid(string:  self.walletAddressTextField.text!) {
            self.walletAddressTextFieldController?.setErrorText("Invalid address", errorAccessibilityValue: "Invalid addresss")
            return
        }
        
        if let mnemonic = self.twelvesWordsView.text?.trimmingCharacters(in: .whitespacesAndNewlines), mnemonic != "" {
            
             let walletId = WalletID(address:  self.walletAddressTextField.text!, mnemonic: self.twelvesWordsView.text!)
            
            ApplicationContext.restore(walletId: walletId)
           
            //TODO
            let isWhitelistedData = "" //= ApplicationContext.smartwallet!.encodeIsEoaWhitelisted(eoa: ApplicationContext.account!.first.ethereumAddress)
            
            self.rpc.call(to:self.walletAddressTextField.text!, data:isWhitelistedData, receive: JSONRPCResult<String>.self) { (result) in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                       
                        if (response.result == "0x0000000000000000000000000000000000000000000000000000000000000001") {
                             DispatchQueue.main.async {
                                do {
                                    try self.walletStorage.store(walletID: walletId)
                                } catch (let error) {
                                    print("ERROR "+error.localizedDescription)
                                }
                            }
                            self.navigationController?.displayWalletView(animated: true)
                        } else {
                            ApplicationContext.clear()
                            self.twelvesWordsViewController?.setErrorText("Mnemonic is not valid", errorAccessibilityValue: "Mnemonic is not valid")
                        }
                    }
                    break
                    
                case .failure(_):
                    ApplicationContext.clear()
                    DispatchQueue.main.async {
                     self.twelvesWordsViewController?.setErrorText("An error occured please try again", errorAccessibilityValue: "An error occured please try again")
                    }
                    break
                        
                }
            }
            
            
        } else {
            self.twelvesWordsViewController?.setErrorText("Should not be empty", errorAccessibilityValue: "Should not be empty")
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
       
}

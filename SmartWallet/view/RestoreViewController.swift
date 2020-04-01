//
//  RestoreViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 16/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import RocksideWalletSdk
import MaterialComponents.MaterialTextFields


class RestoreViewController: UIViewController {
    
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
            self.rockside.restoreIdentity(mnemonic: self.twelvesWordsView.text!, address: walletAddressTextField.text!)
           
            self.rockside.identity!.isEOAWhiteListed(eoa: self.rockside.identity!.eoa.ethereumAddress){ (result) in
                switch result {
                case .success(let result):
                    DispatchQueue.main.async {
                       
                        if (result) {
                            try? self.rockside.storeIdentity()
                            self.performSegue(withIdentifier: "show-wallet-segue", sender: self)
                        } else {
                            self.twelvesWordsViewController?.setErrorText("Mnemonic is not valid", errorAccessibilityValue: "Mnemonic is not valid")
                        }
                    }
                    break
                    
                case .failure(_):
                     self.twelvesWordsViewController?.setErrorText("An error occured please try again", errorAccessibilityValue: "An error occured please try again")
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

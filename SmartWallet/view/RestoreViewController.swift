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
    
    @IBOutlet weak var wordsTextView: UITextView!
    
    @IBOutlet weak var twelvesWordsView: MDCMultilineTextField!
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
            try? self.rockside.restoreIdentity(mnemonic: self.twelvesWordsView.text!, address: walletAddressTextField.text!)
                       
            self.performSegue(withIdentifier: "show-wallet-segue", sender: self)
        } else {
            self.twelvesWordsViewController?.setErrorText("Should not be empty", errorAccessibilityValue: "Should not be empty")
        }
    }
}

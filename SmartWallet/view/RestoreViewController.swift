//
//  RestoreViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 16/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import RocksideWalletSdk


class RestoreViewController: UIViewController {
    
    @IBOutlet weak var walletAddressTextField: UITextField!
    @IBOutlet weak var wordsTextView: UITextView!
    @IBAction func RestoreAction(_ sender: Any) {
        
        let identityAddress = EthereumAddress(string: walletAddressTextField.text!)
        let identity = Identity(mnemonic:wordsTextView.text, address: identityAddress!)
        self.rockside.identity = identity
        try? self.rockside.store()
        
        self.performSegue(withIdentifier: "show-wallet-segue", sender: self)
        
    }
}

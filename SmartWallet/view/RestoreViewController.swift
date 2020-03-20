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
        
        try? self.rockside.restoreIdentity(mnemonic: self.wordsTextView.text, address: walletAddressTextField.text!)
        
        self.performSegue(withIdentifier: "show-wallet-segue", sender: self)
        
    }
}

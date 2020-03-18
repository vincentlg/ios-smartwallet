//
//  RecoveryViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 06/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit

class RecoveryViewController: UIViewController {

    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var mnemonicLabel: UILabel!
    
    override func viewDidLoad() {
        self.walletAddressLabel.text = self.rockside.identity?.ethereumAddress
        self.mnemonicLabel.text = self.rockside.identity?.hdwallet.mnemonic
    }
    
    @IBAction func ContinueAction(_ sender: Any) {
        
    }
    
    @IBAction func CopyAddressAction(_ sender: Any) {
        UIPasteboard.general.string = self.rockside.identity?.ethereumAddress
    }
}

//
//  ViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 06/02/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import RocksideWalletSdk

class WalletViewController: UIViewController {
    
   
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    let walletTabViewController = WalletTabViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.amountLabel.text = self.rockside.identity?.ethereumAddress
        walletTabViewController.view.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height)
        self.contentView.addSubview(walletTabViewController.view)
    }

    
    
   
}

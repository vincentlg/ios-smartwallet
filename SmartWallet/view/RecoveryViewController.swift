//
//  RecoveryViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 06/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import MessageUI

class RecoveryViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var mnemonicLabel: UILabel!
    
    @IBAction func backupByEmailAction(_ sender: Any) {
        self.sendEmail()
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func CopyAddressAction(_ sender: Any) {
        UIPasteboard.general.string = self.rockside.identity!.ethereumAddress+"\n"+self.rockside.identity!.hdwallet.mnemonic
    }
    
    override func viewDidLoad() {
        self.walletAddressLabel.text = self.rockside.identity?.ethereumAddress
        self.mnemonicLabel.text = self.rockside.identity?.hdwallet.mnemonic
    }
    
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("Wallet Backup")
            mail.setMessageBody("Hi,<br /> <p>Your wallet address: "+self.rockside.identity!.ethereumAddress+"</p><p>Your mnemonic : "+self.rockside.identity!.hdwallet.mnemonic+"</p>", isHTML: true)
            
            self.present(mail, animated: true)
        } else {
            let alertController = UIAlertController(title: "Configure email account", message:
                "You need to configure an email account on your iPhone, in oder to send your wallet backup.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    
}

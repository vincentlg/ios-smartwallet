//
//  RecoveryViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 06/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import MessageUI
import MaterialComponents.MaterialSnackbar
import RocksideWalletSdk

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
        UIPasteboard.general.string = Identity.current!.ethereumAddress+"\n"+Identity.current!.hdwallet.mnemonic
        let snackBarMessage = MDCSnackbarMessage()
        snackBarMessage.text = "Address and recovery phrase copied to clipboard."
        snackBarMessage.duration = 1
        MDCSnackbarManager.show(snackBarMessage)
    }
    
    override func viewDidLoad() {
        self.walletAddressLabel.text = Identity.current!.ethereumAddress
        self.mnemonicLabel.text = Identity.current!.hdwallet.mnemonic
    }
    
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("Wallet Backup")
            mail.setMessageBody("Hi,<br /> <p>Your wallet address: "+Identity.current!.ethereumAddress+"</p><p>Your mnemonic : "+Identity.current!.hdwallet.mnemonic+"</p>", isHTML: true)
            
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

//
//  File.swift
//  SmartWallet
//
//  Created by Fred on 03/09/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import WalletConnect
import JGProgressHUD
import BigInt

class WalletConnectViewController: UIViewController{
    
    var peerMeta: WCPeerMeta?
    var fees: String?
    var actionDetails: String?
    var action: String?
    var gas: String?
    var ethAmount: BigUInt?
    
    var approveHandler: (() -> Void)?
    var rejectHandler: (() -> Void)?
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var actionDetailsLabel: UILabel!
    @IBOutlet weak var feesLabel: UILabel!
    @IBOutlet weak var GasFeesLabel: UILabel!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBAction func reject(_ sender: Any) {
        self.dismiss(animated: true) {
            self.rejectHandler?()
        }
       
    }
    
    @IBAction func approve(_ sender: Any) {
        self.dismiss(animated: true) {
             self.approveHandler?()
        }
    }
    
    public func initWith(peerMeta: WCPeerMeta, action: String, actionDetails: String, gas: String?){
        self.peerMeta = peerMeta
        self.action = action
        self.actionDetails = actionDetails
        self.gas = gas
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.actionLabel.text = self.action
        self.actionDetailsLabel.text = self.actionDetails
        self.nameLabel.text = self.peerMeta?.name
        self.logoImageView.imageFromUrl(urlString: self.peerMeta!.icons[0])
        self.descriptionLabel.text = self.peerMeta?.url
        
        self.GasFeesLabel.isHidden = true
        self.feesLabel.isHidden = true
        
        let gasAmount = BigUInt(hex: self.gas!)
        
        if (self.gas != nil) {
            let hud = JGProgressHUD(style: .dark)
            hud.show(in: self.view)
            Application.updateEthPrice() { (result) in
                switch result {
                case .failure(_), .success(_):
                    DispatchQueue.main.async {
                        hud.dismiss()
                        Application.calculateGasFees(safeGas: BigUInt(hex: self.gas!)!) { (result) in
                                   switch result {
                                   case .success(let fefees):
                                       DispatchQueue.main.async {
                                        self.GasFeesLabel.isHidden = false
                                        self.feesLabel.isHidden = false
                                        
                                        self.feesLabel.text = fefees
                                       }
                                       return
                                   case .failure(_):
                                       self.GasFeesLabel.isHidden = true
                                       self.feesLabel.isHidden = true
                                       return
                                   }
                                   
                               }
                    }
                    break
                }
            }
        }
    }
}

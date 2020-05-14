//
//  TransactionViewCell.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 11/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit

class TransactionViewCell: UITableViewCell {
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var circleImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var txTypeIcon: UIImageView!
    @IBOutlet weak var inError: UIImageView!
    
    var transaction: Transaction?

    
    public func display(transaction: Transaction){
        self.transaction = transaction
        self.typeLabel?.text = transaction.type
        self.dateLabel?.text = transaction.formattedDate
        
        self.inError?.isHidden = !transaction.isInError()
        
        
        if (transaction.value != "0") {
            self.circleImageView.isHidden = false
            self.amountLabel?.text = transaction.formattedAmount
            
            if transaction.isReceive() {
                self.txTypeIcon.image = UIImage(named: "tx-receive")
            } else if transaction.isSend()  {
                self.txTypeIcon.image = UIImage(named: "tx-send")
            }
            
        } else if transaction.isContractCreation() {
                self.txTypeIcon.image = UIImage(named: "tx-newwallet")
                self.amountLabel?.text = ""
        } else {
            self.txTypeIcon.image = nil
            self.circleImageView.isHidden = true
            self.amountLabel?.text = ""
        }
        
        self.txTypeIcon.setImageColor(color: UIColor(hexString: "AF52DE"))
    }
    
    @IBAction func viewTxAction(_ sender: Any) {
        
        if let tx = self.transaction {
            
            UIApplication.shared.open(URL(string: "https://etherscan.io/tx/"+tx.hash)!, options: [:], completionHandler: nil)
        }
        
    }
    
}

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
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var circleImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    public func display(transaction: Transaction){
        self.typeLabel?.text = transaction.type
        self.dateLabel?.text = transaction.formattedDate
        
        if (transaction.value != "0") {
            self.circleImageView.isHidden = false
            self.amountLabel?.text = transaction.formattedAmount
            
            if transaction.isERC {
                self.symbolLabel?.text = transaction.tokenSymbol
            }  else {
                self.symbolLabel?.text = "ETH"
            }
        } else {
            self.circleImageView.isHidden = true
            self.amountLabel?.text = ""
            self.symbolLabel?.text = ""
        }
    }
    
}

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
    
    public func display(transaction: Transaction){
        self.typeLabel?.text = transaction.type
        
        
        if (transaction.value != "0") {
            self.amountLabel?.text = transaction.ethValue
            
            if transaction.isERC {
                self.symbolLabel?.text = transaction.tokenSymbol
            }  else {
                self.symbolLabel?.text = "ETH"
            }
        } else {
            self.amountLabel?.text = ""
            self.symbolLabel?.text = ""
        }
    }
    
}

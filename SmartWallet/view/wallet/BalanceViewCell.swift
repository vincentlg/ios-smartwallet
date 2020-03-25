//
//  BalanceViewCell.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 11/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit

class BalanceViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    
    public func display(balance:TokenBalance){
        self.nameLabel?.text = balance.name
        self.balanceLabel?.text = balance.formattedAmout
        self.symbolLabel?.text = balance.symbol
    }
}

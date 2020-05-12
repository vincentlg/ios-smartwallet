//
//  TokenTableViewCell.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 27/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit

class TokenTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    
    public func display(token:Token){
        self.nameLabel?.text = token.name
        self.symbolLabel?.text = token.symbol
    }
}

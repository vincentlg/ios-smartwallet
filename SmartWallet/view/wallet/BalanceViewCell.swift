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
    @IBOutlet weak var tokenImage: UIImageView!
    
    public func display(balance:TokenBalance){
        self.nameLabel?.text = balance.symbol
        
        let price: Double?
        if balance.symbol == "ETH"{
            price = Application.ethPrice
        } else {
            price = Application.tokenPrices?[balance.address]?["usd"]
        }
        
        self.balanceLabel?.text = balance.formattedBalance()
        let fiatValue = balance.fiatValue(tokenPrice: price)
        
        if  fiatValue != 0 {
            self.balanceLabel!.text = self.balanceLabel!.text!+" / $"+String(format: "%.2f", fiatValue)
        }
        
        self.symbolLabel?.text = ""
        
        
        
        tokenImage.imageFromUrl(urlString: balance.img){ () in
            if self.tokenImage.image == nil {
                self.symbolLabel?.text = balance.symbol
                self.tokenImage.image = UIImage(named: "round")
            }
        }
        
        
      
    }
}

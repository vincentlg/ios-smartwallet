//
//  OwnerTableViewCell.swift
//  SmartWallet
//
//  Created by Fred on 24/08/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit


class OwnerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addressLabel: UILabel!
    
    public func display(address:String){
        
        if address == Application.account!.first.ethereumAddress.lowercased() {
            self.addressLabel.text = "Moonkey (\(address))"
        } else {
            self.addressLabel.text = address
        }
        
       
        
        
    }
}

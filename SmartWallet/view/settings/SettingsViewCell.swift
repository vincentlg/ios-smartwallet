//
//  SettingsViewCell.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 08/04/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit

class SettingsViewCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
 
    var item: ItemSettings?
    
    func display(item: ItemSettings) {
        self.item = item
        self.itemLabel.text = item.label
        self.itemImageView.image = UIImage(named: item.iconName)
    }
}

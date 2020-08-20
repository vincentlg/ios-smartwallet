//
//  ListItemView.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 24/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit

class ListItemView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 15;
        self.layer.masksToBounds = true;
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(hexString: "#DCDCDC").cgColor
    }
    
}

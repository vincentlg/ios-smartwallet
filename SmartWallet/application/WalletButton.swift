//
//  WalletButton.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 24/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit

class WalletButton: UIButton {
    
    required init() {
        super.init(frame: .zero)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    func initialize() {
        self.backgroundColor = UIColor(hexString: "0080eb")
        self.layer.cornerRadius = 5;
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.setContentCompressionResistancePriority(.required, for: .vertical)
        self.titleLabel?.font = .systemFont(ofSize: 16)
        self.titleLabel?.textColor = UIColor.white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel?.textColor = UIColor.white
    }
    
    func select() {
         self.backgroundColor = UIColor(hexString: "0080eb")
    }
    
    func deselect() {
        self.backgroundColor = .clear
    }
}

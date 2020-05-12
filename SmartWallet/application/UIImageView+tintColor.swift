//
//  UIImageView+tintColor.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 12/05/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit


extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}

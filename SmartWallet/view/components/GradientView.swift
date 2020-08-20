//
//  GradientView.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 23/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//
import UIKit


class GradientView: UIView {
    override open class var layerClass: AnyClass {
       return CAGradientLayer.classForCoder()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.colors = [UIColor(hexString: "354087").cgColor, UIColor(hexString: "101a3e").cgColor]
    }
}

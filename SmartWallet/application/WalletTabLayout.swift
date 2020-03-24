//
//  WalletTabLayout.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 24/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import Tabman


class WalletTabLayout: TMBarLayout {
    
    // MARK: Properties
    
    internal let stackView = UIStackView()
    
    // MARK: Lifecycle
    
    open override func layout(in view: UIView) {
        super.layout(in: view)
        self.contentMode = .fit
        
        view.addSubview(stackView)
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        stackView.spacing = 5
        
    }
    
    open override func insert(buttons: [TMBarButton], at index: Int) {
        super.insert(buttons: buttons, at: index)
        
        for button in buttons {
            stackView.addArrangedSubview(button)
        }
    }
    
    open override func remove(buttons: [TMBarButton]) {
        super.remove(buttons: buttons)
        
        for button in buttons {
            stackView.removeArrangedSubview(button)
            button.removeFromSuperview()
        }
    }
    
}



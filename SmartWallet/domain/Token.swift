//
//  Token.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 11/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation

struct Token: Codable {
    
    var symbol: String
    var description:String?
    var address: String
    
    var name: String {
        if let _name = description {
            return _name
        }
        
        return symbol
    }
    
}

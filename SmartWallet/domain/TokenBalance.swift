//
//  TokenBalance.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 11/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation
import BigInt

struct TokenBalance {
    
    var name: String
    var symbol: String
    var address: String?     
    var balance: String = "0"
    
    
    var formattedAmout: String {
        let value = (self.balance as NSString).floatValue
        return String(format: "%.3f", value)+" "+self.symbol
    }
}

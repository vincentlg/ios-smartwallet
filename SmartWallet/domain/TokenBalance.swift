//
//  TokenBalance.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 11/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation
import BigInt
import RocksideWalletSdk

struct TokenBalance {
    
    var name: String
    var symbol: String
    var img: String?
    var address: String?     
    var balance: BigInt?
    
    
    var formattedAmout: String {
        let value = (self.balaceString.replacingOccurrences(of: ",", with: ".") as NSString).floatValue
        return String(format: "%.3f", value)+" "+self.symbol
    }
    
    var  balaceString: String {
        
        guard let balanceValue = self.balance else {
            return "0"
        }
        
        let etherFormatter = EtherNumberFormatter()
        return etherFormatter.string(from: balanceValue)
    }
    
}

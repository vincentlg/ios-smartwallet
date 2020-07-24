//
//  Token.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 11/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation
import RocksideWalletSdk
import BigInt

struct Token: Codable {
    
    var symbol: String
    var decimals:Int
    var address: String
    var img: String?
    
    
    func formatAmount(amount: BigInt) -> String {
        let etherFormatter = EtherNumberFormatter()
        return etherFormatter.string(from: amount, decimals: self.decimals)
    }
    
    func amountFrom(value: String) -> BigInt? {
        let etherFormatter = EtherNumberFormatter()
        return etherFormatter.number(from: value, decimals: self.decimals)
    }
}

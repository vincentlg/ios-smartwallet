//
//  TokenBalance.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 11/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation
import BigInt
import web3


struct TokenBalance:Codable {
    
    var symbol: String
    var balance: BigUInt?
    var decimals:Int
    var address: String
    
    
    var img: String {
        return "https://img.paraswap.network/\(self.symbol).png"
    }
    
    var  formattedBalance: String {
        
        guard let balanceValue = self.balance else {
            return "0"
        }
        
        return self.shortAmount(amount: BigInt(balanceValue))+" "+self.symbol
       
    }
    
    func formatAmount(amount: BigInt) -> String {
        let etherFormatter = EtherNumberFormatter()
        return etherFormatter.string(from: amount, decimals: self.decimals)
    }
    
    func shortAmount(amount: BigInt) -> String {
        let amount = formatAmount(amount: amount)
        return  String(format: "%.3f", (amount.replacingOccurrences(of: ",", with: ".") as NSString).floatValue)
    }
    
    func amountFrom(value: String) -> BigInt? {
        let etherFormatter = EtherNumberFormatter()
        return etherFormatter.number(from: value, decimals: self.decimals)
    }
    
    var ethereumAddress: web3.EthereumAddress {
        return web3.EthereumAddress(self.address)
    }
    
}

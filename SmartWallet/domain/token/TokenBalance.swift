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

    var token: Token?
    var balance: BigUInt?
    var address: String
    
    
    var img: String? {
        self.token?.img
    }
    
    var  formattedBalance: String {
        
        guard let balanceValue = self.balance else {
            return "0"
        }
        
        guard let tok = self.token else {
            return "error"
        }
        
        return tok.shortAmount(amount: BigInt(balanceValue))+" "+self.symbol
       
    }
    
    var ethereumAddress: web3.EthereumAddress {
        return web3.EthereumAddress(self.address)
    }
    
}

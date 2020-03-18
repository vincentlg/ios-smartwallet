//
//  Transaction.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 11/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation
import UIKit
import RocksideWalletSdk
import BigInt


struct Transaction: Codable {
    
    var hash: String
    var from: String
    var to: String
    var value: String
    var blockNumber: String
    var contractAddress: String
    var tokenSymbol: String?
    var tokenName: String?
 
    var block: Int {
        return Int(blockNumber)!
    }
}

extension Transaction {
    
    var type: String {
        if from == walletaddress.lowercased() && value != "0" {
            return "Send"
        }
        
        if to == walletaddress.lowercased() && value != "0" {
            return "Receive"
        }
        
        if to != walletaddress.lowercased() && from != walletaddress.lowercased() {
            return "Wallet creation"
        }
        
        if from == walletaddress.lowercased() && value == "0" {
            return "Contract call"
        }
        
        if to == walletaddress.lowercased() && value == "0" {
            return "Relay"
        }
        
        return "Unknown"
    }
    
    var ethValue: String {
        let fullFormatter = EtherNumberFormatter()
        return fullFormatter.string(from: BigInt(value)! )
    }
    
    var isERC: Bool {
        if let _ = self.tokenSymbol  {
            return true
        }
        return false
    }
    
}

extension Transaction {
    
    var walletaddress: String {
        return (UIApplication.shared.delegate as! AppDelegate).rockside!.identity!.ethereumAddress
    }
    
}

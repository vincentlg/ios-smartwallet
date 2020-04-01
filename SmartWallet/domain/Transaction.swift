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
    var timeStamp: String?
 
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
    
    var formattedAmount: String {
        let fullFormatter = EtherNumberFormatter()
        let ethValue = fullFormatter.string(from: BigInt(value)!)
        
        let floatValue = (ethValue.replacingOccurrences(of: ",", with: ".")  as NSString).floatValue
        let stringValue = String(format: "%.3f", floatValue)
        if let symbole = self.tokenSymbol {
            return stringValue+" "+symbole
        }
        
        return stringValue+" ETH"
        
    }
    
    var isERC: Bool {
        if let _ = self.tokenSymbol  {
            return true
        }
        return false
    }
    
    var formattedDate: String? {
        
        if let tmpStp = self.timeStamp, let value = Double(tmpStp) {
            let date = Date(timeIntervalSince1970:value)
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMMM d, HH:mm"
            
            return dateFormatterPrint.string(from: date)
        }
        return nil
    }
}

extension Transaction {
    
    var walletaddress: String {
        return (UIApplication.shared.delegate as! AppDelegate).rockside!.identity!.ethereumAddress
    }
    
}

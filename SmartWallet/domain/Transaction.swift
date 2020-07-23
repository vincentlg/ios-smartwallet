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
    var isError: String?
 
    var block: Int {
        return Int(blockNumber)!
    }
}

enum TransactionType: String {
    case Send = "Send", Receive = "Receive", WalletCreation = "Wallet creation", ContractCall = "Contract call", Relay = "Relay", Unknown = "Unknonw"
}

extension Transaction {
    
    func isContractCreation() -> Bool {
       return to != walletaddress.lowercased() && from != walletaddress.lowercased()
    }
    
    func isSend() -> Bool {
       return from == walletaddress.lowercased() && value != "0"
    }
    
    func isReceive() -> Bool {
        return to == walletaddress.lowercased() && value != "0"
    }
    
    func isInError() -> Bool {
        return isError == "1"
    }
    
    var type: TransactionType {
        if  isSend() {
            return .Send
        }
        
        if isReceive() {
            return .Receive
        }
        
        if isContractCreation() {
            return .WalletCreation
        }
        
        if from == walletaddress.lowercased() && value == "0" {
            return .ContractCall
        }
        
        if to == walletaddress.lowercased() && value == "0" {
            return .Relay
        }
        
        return .Unknown
    }
    
    var formattedAmount: String {
        let fullFormatter = EtherNumberFormatter()
        let ethValue = fullFormatter.string(from: BigInt(value)!)
        
        let floatValue = (ethValue.replacingOccurrences(of: ",", with: ".")  as NSString).floatValue
        let stringValue = String(format: "%.3f", floatValue)
       
        return stringValue+" "+symbol
        
    }

    var symbol: String {
        if let symbole = self.tokenSymbol {
            return symbole
        }
               
       return "ETH"
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
        return  Identity.current!.ethereumAddress
    }
    
}

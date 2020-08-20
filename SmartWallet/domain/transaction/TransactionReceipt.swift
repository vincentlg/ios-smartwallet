//
//  TransactionReceipt.swift
//  RocksideWalletSdk
//
//  Created by Frederic DE MATOS on 20/03/2020.
//  Copyright © 2020 Rockside. All rights reserved.
//

import Foundation

public struct TransactionReceipt:Codable {
    public var block_hash: String?
    public var status: Int
    public var block_number: Int?
    public var logs: [Log]
}

public struct Log:Codable {
    public var data: String
    public var topics: [String]
    
    
    public func dataAsAddress() -> String {
        return "0x"+self.data.suffix(40)
    }
}



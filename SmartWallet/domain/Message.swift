//
//  Message.swift
//  WalletSdk
//
//  Created by Frederic DE MATOS on 18/02/2020.
//  Copyright © 2020 Rockside. All rights reserved.
//

import Foundation
import web3

public protocol Message {
    func hash(chainID: Int, verifyingContract: String) -> String 
}


public struct TxMessage: Message {
    let signer: String
    let to: String
    let data: String
    let nonce: Int
    
    public init(signer: String, to: String, data: String, nonce: Int) {
        self.signer = signer
        self.to = to
        self.data = data
        self.nonce = nonce
    }
    
    
    public func hash(chainID: Int, verifyingContract: String) -> String {
        let jsonString = """
        {
          "types": {
              "EIP712Domain": [
                  {"name": "verifyingContract", "type": "address"},
                  {"name": "chainId", "type": "uint256"},
              ],
              "TxMessage": [
                  {"name": "signer", "type": "address"},
                  {"name": "to", "type": "address"},
                  {"name": "data", "type": "bytes"},
                  {"name": "nonce", "type": "uint256"}
              ]
          },
          "primaryType": "TxMessage",
          "domain": {
              "chainId": \(chainID),
              "verifyingContract": "\(verifyingContract)"
          },
          "message": {
              "signer": "\(signer)",
              "to": "\(to)",
              "data": "\(data)",
              "nonce": \(nonce)
            }
        }
        """
        let typedData = try! JSONDecoder().decode(TypedData.self, from: jsonString.data(using: .utf8)!)
        return try! typedData.signableHash().web3.hexString
    }
}






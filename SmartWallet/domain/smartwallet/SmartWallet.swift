//
//  Message.swift
//  WalletSdk
//
//  Created by Frederic DE MATOS on 18/02/2020.
//  Copyright © 2020 Rockside. All rights reserved.
//

import Foundation
import web3
import BigInt
public protocol Message {
    func hash(chainID: Int, verifyingContract: String) -> String 
}

public protocol SmartWallet {
    init(address: String, rpc: RpcClient)
    var ethereumAddress: String { get }
    
    func getNonce(completion: @escaping (Result<(BigUInt), Error>) -> Void)  -> Void 
    func getTransactionHash(to: web3.EthereumAddress, value:BigUInt, data: Data, nonce: BigUInt, completion: @escaping (Result<(String), Error>) -> Void)  -> Void
    func getTransactionHashWithNonce(to: web3.EthereumAddress, value:BigUInt, data: Data, completion: @escaping (Result<(String), Error>) -> Void)  -> Void
    func encodeExecute(to: web3.EthereumAddress, value:BigUInt, data: Data, signature: Data) -> String
    
    //func encodeIsEoaWhitelisted(eoa: String) -> String
    //func encodeExecute(to: String, value: BigUInt, data: Data)  -> String
    //func encodeUpdateWhiteList(eoa: String, value:Bool) -> String
}






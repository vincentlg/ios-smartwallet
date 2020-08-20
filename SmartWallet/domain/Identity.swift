//
//  Identity.swift
//  WalletSdk
//
//  Created by Frederic DE MATOS on 20/02/2020.
//  Copyright © 2020 Rockside. All rights reserved.
//

import Foundation
import BigInt
import web3

public struct RelayParamsRequest: Codable {
    public let account: String
    public let channel_id: String
}

public struct RelayParamsResponse: Codable {
    public let nonce: String
    public let gas_prices: GasPrices
}

public struct GasPrices:Codable {
    let fastest: String
    let fast: String
    let standard: String
    let safelow: String
    
}

public struct Identity {
    public let address: EthereumAddress
    
    //TODO
    public static var forwarder:String = "0x641d5315d213EA8eb03563f992c7fFfdd677D0cC"
    
    let rpc = RpcClient()
    
    public init(address: EthereumAddress){
        self.address = address
    }
    
    public func hashTx(signer: String, data: String, nonce: Int, chainID: Int) -> String{
        let txMessage = TxMessage(signer: signer, to: self.ethereumAddress, data: data, nonce: nonce)
        return txMessage.hash(chainID: chainID, verifyingContract:Identity.forwarder)
    }
    
    public var ethereumAddress: String {
        return self.address.description
    }
    
 
    public func encodeGetNonce(account: String, channel: Int = 0) -> String {
        
        let function = Function(name: "getNonce", parameters: [.address, .uint(bits: 128)])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [EthereumAddress(string: account)!, 0])
           
        return encoder.data.hexValue
    }
    
    
    public func encodeUpdateWhiteList(eoa: String, value:Bool) -> String {
        let function = updateOwners(contract: web3.EthereumAddress(self.ethereumAddress), eoa: web3.EthereumAddress(eoa), value: value)
        let transaction = try? function.transaction()
                  
        return transaction!.data!.hexValue
    }
    
    public func encodeIsEoaWhitelisted(eoa: String) -> String {
        let function = Function(name: "owners", parameters: [.address])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [EthereumAddress(string: eoa)!])
        
         return encoder.data.hexValue
    }
    
    public func encodeExecute(to: String, value: BigUInt, data: Data)  -> String {
        let function = execute(contract: web3.EthereumAddress(self.ethereumAddress), to: web3.EthereumAddress(to), value: value, data: data)
        let transaction = try? function.transaction()
             
        return transaction!.data!.hexValue
    }
}


//MARK: SmartWallet Contract Functions

public struct execute: ABIFunction {
    public static let name = "execute"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public var contract: web3.EthereumAddress
    public let from: web3.EthereumAddress?

    public let to: web3.EthereumAddress
    public let value: BigUInt
    public let data: Data

    public init(contract: web3.EthereumAddress,
                from: web3.EthereumAddress? = nil,
                to: web3.EthereumAddress,
                value: BigUInt, data:Data) {
        self.contract = contract
        self.from = from
        self.to = to
        self.value = value
        self.data = data
    }

    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(to)
        try encoder.encode(value)
        try encoder.encode(data)
    }
}

public struct updateOwners: ABIFunction {
    public static let name = "updateOwners"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public var contract: web3.EthereumAddress
    public let from: web3.EthereumAddress?

    public let eoa: web3.EthereumAddress
    public let value: Bool

    public init(contract: web3.EthereumAddress,
                from: web3.EthereumAddress? = nil,
                eoa: web3.EthereumAddress,
                value: Bool) {
        self.contract = contract
        self.from = from
        self.eoa = eoa
        self.value = value
    }

    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(eoa)
        try encoder.encode(value)
    }
}


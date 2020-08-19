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
    public let hdwallet: HDWallet
    public let address: EthereumAddress
    
    public static var current: Identity?
    
    static let identityStorage = IdentityStorage()
    //TODO
    public static var forwarder:String = "0x641d5315d213EA8eb03563f992c7fFfdd677D0cC"
    public static var chainID = 1
    
    let rpc = RpcClient()
    
    public init(mnemonic: String, address: EthereumAddress){
        self.hdwallet = HDWallet(mnemonic: mnemonic)
        self.address = address
    }
    
    public func signTx(data: String, nonce: Int) -> String{

        let txMessage = TxMessage(signer: self.eoa.ethereumAddress, to: self.ethereumAddress, data: data, nonce: nonce)
        
        let txMessageHash = txMessage.hash(chainID: Identity.chainID, verifyingContract:Identity.forwarder)
        
        return self.eoa.sign(hash: Data(hex:txMessageHash)!).hexValue
        
    }
    
    public var eoa: PrivateKey {
        return self.hdwallet.getKey(at: Ethereum().derivationPath(at: 0))
    }
    
    public var ethereumAddress: String {
        return self.address.description
    }
    
 
    public func getNonce(channel: String = "0", completion: @escaping (Result<BigInt, Error>) -> Void)  -> Void {
        //TODO
        return self.rpc.getNonce(forwarderAddress:Identity.forwarder, eoa: self.eoa.ethereumAddress, completion: completion)
    }
    
    public func getBalance(completion: @escaping (Result<BigUInt, Error>) -> Void)  -> Void {
        return self.rpc.getBalance(account: self.ethereumAddress, completion: completion)
    }
    
    public func encodeUpdateWhiteList(eoa: String, value:Bool) -> String {
        let function = updateOwners(contract: web3.EthereumAddress(self.ethereumAddress), eoa: web3.EthereumAddress(eoa), value: value)
        let transaction = try? function.transaction()
                  
        return transaction!.data!.hexValue
    }
    
    public func encodeBatch(to: String, value: BigUInt, data: Data)  -> String {
        let function = batch(contract: web3.EthereumAddress(self.ethereumAddress), to: web3.EthereumAddress(to), value: value, data: data)
        let transaction = try? function.transaction()
             
        return transaction!.data!.hexValue
    }
    
    public func getErc20Balance(ercAddress: String, completion: @escaping (Result<BigUInt, Error>) -> Void)  -> Void {
        return self.rpc.getErc20Balance(ercAddress: ercAddress, account: self.ethereumAddress, completion: completion)
    }
    
    public func isEOAWhiteListed(eoa: String, completion: @escaping (Result<Bool, Error>) -> Void)  -> Void {
        return self.rpc.isEOAWhitelistedOn(identityAddress: self.ethereumAddress, eoa: eoa, completion: completion)
    }
    
    public func encodeExecute(to: String, value: BigUInt, data: Data)  -> String {
        let function = execute(contract: web3.EthereumAddress(self.ethereumAddress), to: web3.EthereumAddress(to), value: value, data: data)
        let transaction = try? function.transaction()
             
        return transaction!.data!.hexValue
    }
    
    static public func restoreIdentity(mnemonic:String, address: String) {
        let identityAddress = EthereumAddress(string: address)
        let identity = Identity(mnemonic: mnemonic, address: identityAddress!)
        self.current = identity
    }

    static public func storeIdentity() throws {
        guard let id = self.current else {
            let error = NSError(domain: "no identity", code: 0, userInfo: nil)
            throw error
        }
        
        try self.identityStorage.store(identity: id)
    }
    
    static public func clearIdentity() throws {
        try self.identityStorage.clear()
    }
    
    static public func retrieveIdentity() throws -> Identity? {
        let identityId = try self.identityStorage.retrieve()
        self.current = Identity(mnemonic: identityId.mnemonic, address: EthereumAddress(string: identityId.address)!)
        return self.current
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

public struct Call {
    var to: String
    var value: Int
    var data: String
}

public struct batch: ABIFunction {
    public static let name = "batch"
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


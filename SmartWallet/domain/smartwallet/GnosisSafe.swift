
//
//  GnosisSafe.swift
//  SmartWallet
//
//  Created by Fred on 20/08/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation
import web3
import BigInt

public struct GnosisSafe: SmartWallet {
    
    public let address: web3.EthereumAddress
    
    public let client: EthereumClient
    
    public init(address: String,  rpc: EthereumClient){
        self.address = web3.EthereumAddress(address)
        self.client = rpc
    }
    
    public var ethereumAddress: String {
        return self.address.value
    }
    
    public func encodeAddOwnerWithThreshold(owner: web3.EthereumAddress, threshold: BigUInt) -> String {
        let function = AddOwnerWithThresholdFunc(contract: self.address, owner: owner, threshold: threshold)
        
        let transaction = try? function.transaction()
        
        return transaction!.data!.hexValue
        
    }
    
    public func encodeExecute(to: web3.EthereumAddress, value:BigUInt, data: Data, safeTxGas: BigUInt, baseGas: BigUInt, gasPrice: BigUInt, refundReceiver: web3.EthereumAddress, signature: Data) -> String {
        let function = ExecTransactionFunc(contract: self.address,
                                           gasPrice: gasPrice,
                                           to: to,
                                           value: value,
                                           data: data,
                                           safeTxGas: safeTxGas,
                                           baseGas: baseGas,
                                           refundReceiver: refundReceiver,
                                           signatures: signature)
        
        let transaction = try? function.transaction()
        
        return transaction!.data!.hexValue
    }
    
    public func getNonce(completion: @escaping (Result<(BigUInt), Error>) -> Void)  -> Void {
        let function = NonceFunc(contract: self.address)
        let transaction = try! function.transaction()
        
        self.client.eth_call(transaction) { (error, result) in
        
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let res = result else {
                completion(.failure(NSError(domain: "Nil result", code: 0, userInfo: nil)))
                return
            }
            completion(.success(BigUInt(hex: res)!))
        }
    }
    
    
    public func getOwners(completion: @escaping (Result<([String]), Error>) -> Void)  -> Void {
        
        let function = GetOwnersFunc(contract: self.address)
        let transaction = try! function.transaction()
        
        self.client.eth_call(transaction) { (error, result) in
            
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let res = result else {
                completion(.failure(NSError(domain: "Nil result", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decoded = try web3.ABIDecoder.decodeData(res, types: [ABIArray<web3.EthereumAddress>.self])
                let addresses: [web3.EthereumAddress] = try decoded.first!.decodedArray()
                completion(.success(addresses.map { $0.value}))
            } catch (let error) {
                completion(.failure(error))
            }
            
        }
        
    }
    
    public func isOwner(owner: web3.EthereumAddress, completion: @escaping (Result<(Bool), Error>) -> Void)  -> Void {
        let function = IsOwnerFunc(contract: self.address, owner: owner)
        let transaction = try! function.transaction()
        
        self.client.eth_call(transaction) { (error, result) in
        
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let res = result else {
                completion(.failure(NSError(domain: "Nil result", code: 0, userInfo: nil)))
                return
            }
            
            let decoded = try! ABIDecoder.decodeData(res, types: [Bool.self])
            let result: Bool = try! decoded.first!.decoded()
            
            completion(.success(result))
        }
    }
    
    public func getTransactionHashWithNonce(to: web3.EthereumAddress, value:BigUInt, data: Data, safeTxGas: BigUInt, baseGas: BigUInt, gasPrice: BigUInt, refundReceiver: web3.EthereumAddress, completion: @escaping (Result<(String), Error>) -> Void)  -> Void {
        
        self.getNonce() { (result) in
            switch result {
            case .success(let nonce):
                self.getTransactionHash(to: to, value: value, data: data, safeTxGas: safeTxGas, baseGas: baseGas, gasPrice: gasPrice, refundReceiver: refundReceiver, nonce: nonce, completion: completion)
                return
                
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
        
        
    }
    
    public func getTransactionHash(to: web3.EthereumAddress, value:BigUInt, data: Data, safeTxGas: BigUInt = BigUInt(0), baseGas: BigUInt = BigUInt(0), gasPrice: BigUInt = BigUInt(0), refundReceiver: web3.EthereumAddress = .zero, nonce: BigUInt, completion: @escaping (Result<(String), Error>) -> Void)  -> Void {
        
        let function = GetTransactionHashFunc(contract: self.address,
                                                     gasPrice: gasPrice,
                                                     to: to,
                                                     value: value,
                                                     data: data,
                                                     safeTxGas: safeTxGas,
                                                     baseGas: baseGas,
                                                     refundReceiver: refundReceiver,
                                                     nonce: nonce)
               
        let transaction = try! function.transaction()
        
        self.client.eth_call(transaction) { (error, result) in
        
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let res = result else {
                completion(.failure(NSError(domain: "Nil result", code: 0, userInfo: nil)))
                return
            }
            
           completion(.success(res))
        }
    }
    
}

//MARK: Gnosis Safe func
public struct GetTransactionHashFunc: ABIFunction {
    public static let name = "getTransactionHash"
    
    public let gasPrice: BigUInt?
    public let gasLimit: BigUInt?
    public var contract: web3.EthereumAddress
    public let from: web3.EthereumAddress?
    
    public let to: web3.EthereumAddress
    
    public var value:BigUInt
    public var data: Data
    public var operation: UInt8
    public var safeTxGas: BigUInt
    public var baseGas: BigUInt
    public var _gasPrice: BigUInt
    public var gasToken: web3.EthereumAddress
    public var refundReceiver: web3.EthereumAddress
    public var _nonce: BigUInt
    
    public init(contract: web3.EthereumAddress,
                from: web3.EthereumAddress? = nil,
                gasPrice: BigUInt = BigUInt(0),
                gasLimit: BigUInt? = nil,
                to: web3.EthereumAddress,
                value: BigUInt,
                data: Data,
                safeTxGas:BigUInt = BigUInt(0),
                baseGas: BigUInt = BigUInt(0),
                refundReceiver: web3.EthereumAddress = .zero,
                nonce: BigUInt) {
        self.contract = contract
        self.from = from
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.to = to
        
        self.value = value
        self.data = data
        self.operation = 0
        self.safeTxGas =  safeTxGas
        self.baseGas = baseGas
        self._gasPrice = gasPrice
        self.gasToken = .zero
        self.refundReceiver = refundReceiver
        
        self._nonce = nonce
    }
    
    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(self.to)
        try encoder.encode(self.value)
        try encoder.encode(self.data)
        try encoder.encode(self.operation)
        try encoder.encode(self.safeTxGas)
        try encoder.encode(self.baseGas)
        try encoder.encode(self._gasPrice)
        try encoder.encode(self.gasToken)
        try encoder.encode(self.refundReceiver)
        try encoder.encode(self._nonce)
    }
}


public struct ExecTransactionFunc: ABIFunction {
    public static let name = "execTransaction"
    
    public let gasPrice: BigUInt?
    public let gasLimit: BigUInt?
    public var contract: web3.EthereumAddress
    public let from: web3.EthereumAddress?
    
    public let to: web3.EthereumAddress
    
    public var value:BigUInt
    public var data: Data
    public var operation: UInt8
    public var safeTxGas: BigUInt
    public var baseGas: BigUInt
    public var _gasPrice: BigUInt
    public var gasToken: web3.EthereumAddress
    public var refundReceiver: web3.EthereumAddress
    public var signatures: Data
    
    public init(contract: web3.EthereumAddress,
                from: web3.EthereumAddress? = nil,
                gasPrice: BigUInt = BigUInt(0),
                gasLimit: BigUInt? = nil,
                to: web3.EthereumAddress,
                value: BigUInt,
                data: Data,
                safeTxGas:BigUInt = BigUInt(0),
                baseGas: BigUInt = BigUInt(0),
                refundReceiver:web3.EthereumAddress = .zero,
                signatures: Data) {
        self.contract = contract
        self.from = from
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.to = to
        
        self.value = value
        self.data = data
        self.operation = 0
        self.safeTxGas = safeTxGas
        self.baseGas = baseGas
        self._gasPrice = gasPrice
        self.gasToken = .zero
        self.refundReceiver = refundReceiver
        self.signatures = signatures
    }
    
    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(self.to)
        try encoder.encode(self.value)
        try encoder.encode(self.data)
        try encoder.encode(self.operation)
        try encoder.encode(self.safeTxGas)
        try encoder.encode(self.baseGas)
        try encoder.encode(self._gasPrice)
        try encoder.encode(self.gasToken)
        try encoder.encode(self.refundReceiver)
        try encoder.encode(self.signatures)
    }
}

public struct NonceFunc: ABIFunction {
    public static let name = "nonce"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public let contract: web3.EthereumAddress
    public let from: web3.EthereumAddress?
    
    
    public init(contract: web3.EthereumAddress,
                from: web3.EthereumAddress? = nil) {
        self.contract = contract
        self.from = from
    }
    
    public func encode(to encoder: ABIFunctionEncoder) throws {}
}


public struct IsOwnerFunc: ABIFunction {
    public static let name = "isOwner"
    
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public var contract: web3.EthereumAddress
    public let from: web3.EthereumAddress?
    
    public let owner: web3.EthereumAddress
    
    public init(contract: web3.EthereumAddress,
                from: web3.EthereumAddress? = nil, owner: web3.EthereumAddress) {
        self.contract = contract
        self.from = from
        self.owner = owner
    }
    
    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(self.owner)
    }
}

public struct GetOwnersFunc: ABIFunction {
    public static let name = "getOwners"
    
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public var contract: web3.EthereumAddress
    public let from: web3.EthereumAddress?
    
    
    public init(contract: web3.EthereumAddress,
                from: web3.EthereumAddress? = nil) {
        self.contract = contract
        self.from = from
    }
    
    public func encode(to encoder: ABIFunctionEncoder) throws {}
}



public struct AddOwnerWithThresholdFunc: ABIFunction {
    public static let name = "addOwnerWithThreshold"
    
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public var contract: web3.EthereumAddress
    public let from: web3.EthereumAddress?
    
    public let owner: web3.EthereumAddress
    public let threshold: BigUInt
    
    public init(contract: web3.EthereumAddress,
                from: web3.EthereumAddress? = nil,
                owner: web3.EthereumAddress,
                threshold: BigUInt) {
        self.contract = contract
        self.from = from
        self.owner = owner
        self.threshold = threshold
    }
    
    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(self.owner)
        try encoder.encode(self.threshold)
    }
}


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
    public let rpc: RpcClient
    
    public init(address: String,  rpc: RpcClient){
        self.address = web3.EthereumAddress(address)
        self.rpc = rpc
    }
    
    public var ethereumAddress: String {
        return self.address.value
    }
    
    
    public func encodeExecute(to: web3.EthereumAddress, value:BigUInt, data: Data, signature: Data) -> String {
        let function = ExecTransactionFunc(contract: self.address,
                                           to: to,
                                           value: value,
                                           data: data,
                                           signatures: signature)
        
        let transaction = try? function.transaction()
        
        return transaction!.data!.hexValue
    }
    
    public func getNonce(completion: @escaping (Result<(BigUInt), Error>) -> Void)  -> Void {
        self.rpc.call(to: self.ethereumAddress, data: self.encodeGetNonce(), receive: JSONRPCResult<String>.self) { (result) in
            switch result {
            case .success(let response):
                completion(.success(BigUInt(hex: response.result)!))
                return
                
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
    }
    
    public func getTransactionHashWithNonce(to: web3.EthereumAddress, value:BigUInt, data: Data, completion: @escaping (Result<(String), Error>) -> Void)  -> Void {
        
        self.getNonce() { (result) in
            switch result {
            case .success(let nonce):
                self.getTransactionHash(to: to, value: value, data: data, nonce: nonce, completion: completion)
                return
                
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
        
        
    }
    
    public func getTransactionHash(to: web3.EthereumAddress, value:BigUInt, data: Data, nonce: BigUInt, completion: @escaping (Result<(String), Error>) -> Void)  -> Void {
        
        self.rpc.call(to: self.ethereumAddress, data: self.encodeGetTransactionHash(to: to, value: value, data: data, nonce: nonce), receive: JSONRPCResult<String>.self) { (result) in
            switch result {
            case .success(let response):
                completion(.success(response.result))
                return
                
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
    }
    
    private func encodeGetTransactionHash(to: web3.EthereumAddress, value:BigUInt, data: Data, nonce: BigUInt) -> String {
        
        let function = GetTransactionHashFunc(contract: self.address,
                                              to: to,
                                              value: value,
                                              data: data,
                                              nonce: nonce)
        
        let transaction = try? function.transaction()
        
        return transaction!.data!.hexValue
    }
    
    private func encodeGetNonce() -> String {
        let function = NonceFunc(contract: self.address)
        let transaction = try? function.transaction()
        
        return transaction!.data!.hexValue
    }
    
}

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
                gasPrice: BigUInt? = nil,
                gasLimit: BigUInt? = nil,
                to: web3.EthereumAddress,
                value: BigUInt,
                data: Data,
                nonce: BigUInt) {
        self.contract = contract
        self.from = from
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.to = to
        
        self.value = value
        self.data = data
        self.operation = 0
        self.safeTxGas =  BigUInt(0)
        self.baseGas = BigUInt(0)
        self._gasPrice = BigUInt(0)
        self.gasToken = .zero
        self.refundReceiver = .zero
        
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
                gasPrice: BigUInt? = nil,
                gasLimit: BigUInt? = nil,
                to: web3.EthereumAddress,
                value: BigUInt,
                data: Data,
                signatures: Data) {
        self.contract = contract
        self.from = from
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.to = to
        
        self.value = value
        self.data = data
        self.operation = 0
        self.safeTxGas =  BigUInt(0)
        self.baseGas = BigUInt(0)
        self._gasPrice = BigUInt(0)
        self.gasToken = .zero
        self.refundReceiver = .zero
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


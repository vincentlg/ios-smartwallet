//
//  RpcClient.swift
//  RocksideWalletSdk
//
//  Created by Frederic DE MATOS on 20/03/2020.
//  Copyright © 2020 Rockside. All rights reserved.
//

import Foundation
import BigInt


public struct JSONRPCRequest<T: Encodable>: Encodable {
    public let jsonrpc: String
    public let method: String
    public let params: T
    public let id: Int
    
    public init(jsonrpc: String, method: String, params: T, id: Int) {
        self.jsonrpc = jsonrpc
        self.method = method
        self.params = params
        self.id = id
    }
    
}

public struct JSONRPCResult<T: Decodable>: Decodable {
    public let id: Int
    public let jsonrpc: String
    public let result: T
}

public struct RpcClient {
    
    public init() {}
    
    var url: String {
        if Identity.chainID == 1 {
            return "https://eth-mainnet.alchemyapi.io/v2/yKy-FkvOSlIgp9W8_mCxhW-HEdISZ7-Y"
        }
        
        return "https://eth-ropsten.alchemyapi.io/v2/KxdHbojr9X0iMOJw8U6fyJTNbNX5Pgid"
    }
    
    public func executeJSONRpc<T:Decodable>(with requestBody: Encodable, receive: T.Type, completion: @escaping (Result<(T), Error>) -> Void) -> URLSessionDataTask {
        
        var request = URLRequest(url: URL(string:url)!)
        request.httpMethod = "POST"
        request.httpBody = requestBody.toJSONData()
        
        return self.execute(with: request, receive: receive, completion: completion)
    }
    
    public func  getErc20Balance(ercAddress: String, account: String, completion: @escaping (Result<BigUInt, Error>) -> Void)  -> Void {
        
        let data = ERC20Encoder.encodeBalanceOf(address:  EthereumAddress(string: account)!).hexValue
        let body = JSONRPCRequest(jsonrpc: "2.0", method: "eth_call", params: [["to":ercAddress, "data":data ]], id: 1)
        
        self.executeJSONRpc(with:body, receive: JSONRPCResult<String>.self) { (result) in
            switch result {
            case .success(let response):
                
                guard let balance = BigUInt(hex: response.result) else {
                    let error = NSError(domain: "invalid result format", code: 0, userInfo: nil)
                    completion(.failure(error))
                    return
                }
                
                completion(.success(balance))
                return
                
            case .failure(let error):
                completion(.failure(error))
                break
            }
        }.resume()
    }
    
    public func getBalance(account: String, completion: @escaping (Result<BigUInt, Error>) -> Void)  -> Void {
        
        let body = JSONRPCRequest(jsonrpc: "2.0", method: "eth_getBalance", params: [account, "latest"], id: 1)
        self.executeJSONRpc(with: body, receive: JSONRPCResult<String>.self) { (result) in
            switch result {
            case .success(let response):
                
                guard let balance = BigUInt(hex: response.result) else {
                    let error = NSError(domain: "invalid result format", code: 0, userInfo: nil)
                    completion(.failure(error))
                    return
                }
                
                completion(.success(balance))
                return
                
            case .failure(let error):
                completion(.failure(error))
                break
            }
        }.resume()
    }
    
    public func isEOAWhitelistedOn(identityAddress: String, eoa: String, completion: @escaping (Result<Bool, Error>) -> Void)  -> Void {
        let function = Function(name: "owners", parameters: [.address])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [EthereumAddress(string: eoa)!])
        
        let body = JSONRPCRequest(jsonrpc: "2.0", method: "eth_call", params: [["to": identityAddress, "data":encoder.data.hexValue ]], id: 1)
        
        return self.executeJSONRpc(with:body, receive: JSONRPCResult<String>.self) { (result) in
            switch result {
            case .success(let response):
                completion(.success(response.result == "0x0000000000000000000000000000000000000000000000000000000000000001"))
                break
            case .failure(let error):
                completion(.failure(error))
                break
            }
        }.resume()
    }
    
    public func getNonce(forwarderAddress: String, eoa: String, completion: @escaping (Result<BigInt, Error>) -> Void)  -> Void {
        let function = Function(name: "getNonce", parameters: [.address, .uint(bits: 128)])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [EthereumAddress(string: eoa)!, 0])
        
        let body = JSONRPCRequest(jsonrpc: "2.0", method: "eth_call", params: [["to": forwarderAddress, "data":encoder.data.hexValue ]], id: 1)
        return self.executeJSONRpc(with:body, receive: JSONRPCResult<String>.self) { (result) in
            switch result {
            case .success(let response):
                completion(.success(BigInt(hex: response.result)!))
                break
            case .failure(let error):
                completion(.failure(error))
                break
            }
        }.resume()
    }
    

        internal func execute<T:Decodable>(with request: URLRequest, receive: T.Type, completion: @escaping (Result<(T), Error>) -> Void) -> URLSessionDataTask {
            return URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let response = response, let data = data else {
                    let error = NSError(domain: "error empty response", code: 0, userInfo: nil)
                    
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse  else {
                    let error = NSError(domain: "error not http response", code: 0, userInfo: nil)
                    completion(.failure(error))
                    return
                }
                
                if  httpResponse.statusCode > 201  {
                    let error = NSError(domain: "error http :\(httpResponse.statusCode) ", code:  httpResponse.statusCode, userInfo: nil)
                    completion(.failure(error))
                    return
                }
                
                guard let result = try? JSONDecoder().decode(T.self, from: data) else {
                   
                    let error = NSError(domain: "error invalide response format", code: 0, userInfo: nil)
                    completion(.failure(error))
                    return
                }
             
                completion(.success((result)))
            }
        }
}

//
//  MoonkeyService.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 09/07/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation
import BigInt

struct DeploySmartwalletRequest: Codable {
    var account: String
}

struct DeploySmartwalletResponse: Codable {
    public let transaction_hash: String
    public let tracking_id: String
}


public struct TransactionDetails: Codable {
    public var transaction_hash: String
    public var tracking_id: String
    public var status: String
    public var receipt: TransactionReceipt?
}

struct RelayRequest: Codable {
    let to: String
    let data: String
    let gas: String
}

public struct RelayResponse: Codable {
    public let transaction_hash: String
    public let tracking_id: String
}

class MoonkeyService {
    
    var network:String {
        
        if (Application.network == .mainnet) {
            return "mainnet"
        }
        
        return "ropsten"
    }
    
    
    public func deploySmartwallet(account: String, completion: @escaping (Result<DeploySmartwalletResponse, Error>) -> Void)  -> Void {
        
        let body = DeploySmartwalletRequest(account: account)
        
        var request = URLRequest(url: URL(string: "https://europe-west1-rockside-showcase.cloudfunctions.net/moonkey-deploy-smartwallet?network="+self.network)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = body.toJSONData()
        
        Http.execute(with: request, receive: DeploySmartwalletResponse.self){ (result) in
            switch result {
            case .success(let response):
                completion(.success(response))
                return
                
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }.resume()
    }
    
    
    public func deployGnosisSafe(account: String, completion: @escaping (Result<DeploySmartwalletResponse, Error>) -> Void)  -> Void {
        
        let body = DeploySmartwalletRequest(account: account)
        
        var request = URLRequest(url: URL(string: "https://europe-west1-rockside-showcase.cloudfunctions.net/test-deploy-gnosis?network="+self.network)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = body.toJSONData()
        
        Http.execute(with: request, receive: DeploySmartwalletResponse.self){ (result) in
            switch result {
            case .success(let response):
                completion(.success(response))
                return
                
            case .failure(let error):
                print(error)
                completion(.failure(error))
                return
            }
        }.resume()
    }
    
    
    public func transactionStatus(trackingID: String, completion: @escaping (Result<TransactionDetails, Error>) -> Void)  -> Void {
        
        var request = URLRequest(url: URL(string: "https://europe-west1-rockside-showcase.cloudfunctions.net/moonkey-tx-infos/"+trackingID+"?network="+self.network)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Http.execute(with: request, receive: TransactionDetails.self){ (result) in
            switch result {
            case .success(let transactionDetails):
                completion(.success(transactionDetails))
                return
                
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }.resume()
        
    }
    
    public func waitTxToBeMined(trackingID: String, completion: @escaping (Result<TransactionReceipt, Error>) -> Void) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { timer in
            self.transactionStatus(trackingID: trackingID) { (result) in
                switch result {
                case .success(let transactionDetails):
                    if let receipt = transactionDetails.receipt, let _ = receipt.block_number {
                        timer.invalidate()
                        completion(.success(receipt))
                    }
                    
                    break
                case .failure(let error):
                    timer.invalidate()
                    completion(.failure(error))
                    break
                }
            }
        }
    }
    
    
    public func relayTransaction(smartWallet: SmartWallet, messageData: String, gas: String = "", completion: @escaping (Result<RelayResponse, Error>) -> Void)  -> Void {
        
        let body = RelayRequest(to: smartWallet.address.value, data: messageData, gas: gas)
        
        var request = URLRequest(url: URL(string: "https://europe-west1-rockside-showcase.cloudfunctions.net/moonkey-tx-relay-message-data?network="+self.network)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = body.toJSONData()
        
        Http.execute(with: request, receive: RelayResponse.self, completion: completion).resume()
    }
    
}

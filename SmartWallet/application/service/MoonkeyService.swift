//
//  MoonkeyService.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 09/07/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation
import RocksideWalletSdk
import BigInt

struct DeploySmartwalletRequest: Codable {
    var account: String
}

struct DeploySmartwalletResponse: Codable {
    public let address: String
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
    let signer: String
    let to: String
    let data: String
    let nonce: String
    let signature: String
    let gas: String
}

public struct RelayResponse: Codable {
    public let transaction_hash: String
    public let tracking_id: String
}

class MoonkeyService {
    
    
        var network:String {
            
            if (Identity.chainID ==  1) {
                return "mainnet"
            }
            
            return "ropsten"
        }
    
        public func deploySmartwallet(completion: @escaping (Result<DeploySmartwalletResponse, Error>) -> Void)  -> Void {
            let mnemonic = Crypto.generateMnemonic(strength: 128)
            let wallet = HDWallet(mnemonic: mnemonic)
            let eoa = wallet.getKey(at: Ethereum().derivationPath(at: 0))
            
            let body = DeploySmartwalletRequest(account: eoa.ethereumAddress)
            
            var request = URLRequest(url: URL(string: "https://europe-west1-rockside-showcase.cloudfunctions.net/moonkey-deploy-smartwallet?network="+self.network)!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = body.toJSONData()
                  
            Http.execute(with: request, receive: DeploySmartwalletResponse.self){ (result) in
                switch result {
                case .success(let response):
                    
                    //TODO Test / Mainthread
                    DispatchQueue.main.async {
                        guard let address = EthereumAddress(string: response.address) else {
                            let error = NSError(domain: "invalid ethereum address", code: 0, userInfo: nil)
                            
                            completion(.failure(error))
                            return
                        }
                        
                        let identity = Identity(mnemonic: mnemonic, address: address)
                        Identity.current = identity
                        completion(.success(response))
                    }
                    return
                    
                case .failure(let error):
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
    
    
    public func relayTransaction(identity: Identity, messageData: String, gas: String = "", completion: @escaping (Result<RelayResponse, Error>) -> Void)  -> Void {
        identity.getNonce() { (result) in
            switch result {
            case .success(let nonce):
                
                //TODO
                let signature = identity.signTx(data: messageData, nonce: Int(nonce.description)!)
                let body = RelayRequest(signer: identity.eoa.ethereumAddress, to: identity.ethereumAddress, data: messageData, nonce: nonce.description, signature: signature, gas: gas)
                
                var request = URLRequest(url: URL(string: "https://europe-west1-rockside-showcase.cloudfunctions.net/moonkey-tx-relay?network="+self.network)!)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                request.httpBody = body.toJSONData()
                      
                Http.execute(with: request, receive: RelayResponse.self, completion: completion).resume()
                break
            case .failure(let error):
                completion(.failure(error))
                break
            }
        }
        
    }

}

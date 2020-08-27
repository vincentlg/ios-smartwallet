//
//  EtherscanService.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 18/05/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation


public struct EtherscanTransactionResponse: Codable {
    var status: String
    var message: String
    var result: [Transaction]
}


public struct EthPriceResponse: Codable {
    var result:EthPrice
}

public struct EthPrice: Codable {
    var ethusd: String
}

public enum TxAction {
    case txlist, txlistinternal, tokentx
}

public class EtherscanService {
    
    private var etherscanApiKey = "HCYC8QMVAN8M5RSMKWT7FFGG2KTU1N3IVG"
    
    
    var url:String {
        if Application.network == .mainnet {
            return "https://api.etherscan.io/api"
        }
        return "https://api-ropsten.etherscan.io/api"
    }
    
    public func ethPrice(completion: @escaping (Result<EthPrice, Error>) -> Void) -> Void {
        let url  = URL(string: self.url+"?module=stats&action=ethprice&apikey&apikey=\(etherscanApiKey)")!
        let request = URLRequest(url:url ,timeoutInterval: Double.infinity)
        
        Http.execute(with: request, receive: EthPriceResponse.self) { (result) in
            switch result {
            case .success(let response):
                completion(.success(response.result))
                return
                
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }.resume()
    }
    
    public func retrieveTransaction(action: TxAction, completion: @escaping (Result<EtherscanTransactionResponse, Error>) -> Void) -> Void {
        
        let url  = URL(string: self.url+"?module=account&action=\(action)&address=\(Application.smartwallet!.address.value)&startblock=0&endblock=99999999&sort=desc&apikey=\(etherscanApiKey)")!
        let request = URLRequest(url:url ,timeoutInterval: Double.infinity)
        
        Http.execute(with: request, receive: EtherscanTransactionResponse.self) { (result) in
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
    
    
}

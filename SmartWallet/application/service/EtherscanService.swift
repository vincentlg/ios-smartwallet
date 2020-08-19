//
//  EtherscanService.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 18/05/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation


struct EtherscanTransactionResponse: Codable{
    var status: String
    var message: String
    var result: [Transaction]
}

enum TxAction {
    case txlist, txlistinternal, tokentx
}

class EtherscanService {

    private var etherscanApiKey = "HCYC8QMVAN8M5RSMKWT7FFGG2KTU1N3IVG"

    
    var url:String {
        if Identity.chainID == 1
        {
            return "https://api.etherscan.io/api"
        }
        
        return "https://api-ropsten.etherscan.io/api"
    }

    public func retrieveTransaction(action: TxAction, completion: @escaping (Result<EtherscanTransactionResponse, Error>) -> Void) -> Void {
        
        //TODO Etherscan URL from Chain ID
        let url  = URL(string: self.url+"?module=account&action=\(action)&address=\(Identity.current!.ethereumAddress)&startblock=0&endblock=99999999&sort=desc&apikey=\(etherscanApiKey)")!
        
        var request = URLRequest(url:url ,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
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

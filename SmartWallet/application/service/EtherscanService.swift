//
//  EtherscanService.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 18/05/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation
import RocksideWalletSdk

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


    public func retrieveTransaction(action: TxAction, completion: @escaping (Result<EtherscanTransactionResponse, Error>) -> Void) -> Void {
        
        let url  = URL(string: "\(self.rockside.chain.etherscanAPIUrl)?module=account&action=\(action)&address=\(self.rockside.identity!.ethereumAddress)&startblock=0&endblock=99999999&sort=desc&apikey=\(etherscanApiKey)")!
        
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
    
    var rockside: Rockside {
        return (UIApplication.shared.delegate as! AppDelegate).rockside!
    }
}

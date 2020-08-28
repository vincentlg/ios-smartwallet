//
//  CoinGeckoService.swift
//  SmartWallet
//
//  Created by Fred on 28/08/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation


public class CoinGeckoService {
    
    
    public func getTokenPrices(tokens: [TokenBalance],  completion: @escaping (Result<[String: [String: Double]], Error>) -> Void)  -> Void {
        
        let addresses = tokens.map {$0.address}.joined(separator: ",")
        var request = URLRequest(url: URL(string: "https://api.coingecko.com/api/v3/simple/token_price/ethereum?contract_addresses=\(addresses)&vs_currencies=usd")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Http.execute(with: request, receive: [String: [String: Double]].self, completion: completion).resume()
    
    }

}

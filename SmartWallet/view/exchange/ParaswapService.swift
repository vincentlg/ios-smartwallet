//
//  ParaswapService.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 30/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation

struct GetTokenResponse: Codable {
    var tokens: [Token]
}

struct GetRateResponse: Codable {
    var priceRoute: PriceRoute
}

struct PriceRoute: Codable {
    var amount: String
    var multiPath: Bool
    var fromUSD: String
    var toUSD: String
    var details: PriceRouteDetails?
    var bestRoute: [Route]
    var others: [Route]?
}

struct PriceRouteDetails: Codable {
    var tokenFrom: String
    var tokenTo: String
    var srcAmount: String
}

struct Route: Codable {
    var exchange: String?
    var amount: String?
    var srcAmount: String?
    var percent: String?
    var rate: String?
    var unit: String?
    var data: RouteData?
}

struct RouteData: Codable {
    var tokenFrom: String
    var tokenTo: String
}

struct GetTxRequest: Codable {
    var priceRoute: PriceRoute
    var srcToken: String
    var destToken: String
    var srcAmount: String
    var destAmount: String
    var userAddress: String
}

struct GetTxResponse:Codable {
    var from: String?
    var to: String?
    var value: String?
    var data: String?
    var gasPrice: String?
    var gas: String?
}

class ParaswapService {
    
    let url = "https://paraswap.io/api/v1/"
    
    public func getTokens(completion: @escaping (Result<[Token], Error>) -> Void) -> Void {
        var request = URLRequest(url: URL(string: url+"tokens/1")!)
        request.httpMethod = "GET"
        
        Http.execute(with: request, receive: GetTokenResponse.self)  { (result) in
            switch result {
            case .success(let response):
                
                var tokens = response.tokens
                tokens.sort {
                    
                    if $0.symbol == "ETH" {
                        return true
                    }
                    
                    if $1.symbol == "ETH" {
                        return false
                    }
                    
                    if $0.symbol == "DAI" {
                        return true
                    }
                    
                    if $1.symbol == "DAI" {
                        return false
                    }
                    
                    return $0.symbol.lowercased() < $1.symbol.lowercased()
                }
                
                completion(.success(tokens))
                return
                
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }.resume()
    }
    
    public func getRate(sourceTokenAddress: String, destTokenAddress: String, amount: String, completion: @escaping (Result<PriceRoute, Error>) -> Void) -> Void {
        
        var request = URLRequest(url: URL(string:  url+"prices/1/"+sourceTokenAddress+"/"+destTokenAddress+"/"+amount)!)
        request.httpMethod = "GET"
        
        Http.execute(with: request, receive: GetRateResponse.self) { (result) in
            switch result {
            case .success(let response):
                completion(.success(response.priceRoute))
                return
                
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }.resume()
    }
    
    public func getParaswapTx(body: GetTxRequest, completion: @escaping (Result<GetTxResponse, Error>) -> Void) -> Void {
        var request = URLRequest(url: URL(string: url+"transactions/1")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = body.toJSONData()
        Http.execute(with: request, receive: GetTxResponse.self, completion: completion).resume()
    }
    
}

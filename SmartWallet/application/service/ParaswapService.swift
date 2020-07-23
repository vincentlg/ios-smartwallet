//
//  ParaswapService.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 30/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation
import RocksideWalletSdk

struct GetTokenResponse: Codable {
    var tokens: [Token]
}

struct GetRateResponse: Codable {
    var priceRoute: PriceRoute
}



class PriceRoute: Codable {
    var amount: String
    var fromUSD: String
    var toUSD: String
    var details: PriceRouteDetails?
    var bestRoute: [BestRoute]
    var others: [OtherRoute]?

}

struct PriceRouteDetails: Codable {
    var tokenFrom: String
    var tokenTo: String
    var srcAmount: String
}

class BestRoute: Codable {
    var exchange: String
    var amount: String
    var srcAmount: String
    var percent: Int
    var data: RouteData?
}

class OtherRoute: Codable {
    var exchange: String
    var unit: String
    var rate: String
}

struct RouteData: Codable {
    var tokenFrom: String
    var tokenTo: String
    var orders: [Order]?
    var path: [String]?
}

struct Order: Codable {
    var chainId: Int
    var exchangeAddress: String
    var makerAddress: String?
    var makerAssetData: String?
    var makerFeeAssetData: String?
    var makerAssetAmount: String?
    var makerFee: String?
    var takerAddress: String?
    var takerAssetData: String?
    var takerFeeAssetData: String?
    var takerAssetAmount: String?
    var takerFee: String?
    var senderAddress: String?
    var feeRecipientAddress: String?
    var expirationTimeSeconds: String?
    var salt: String?
    var signature: String?
    var fillableTakerAssetAmount: String?
    var price: String?
}

struct GetTxRequest: Codable {
    var priceRoute: PriceRoute
    var srcToken: String
    var destToken: String
    var srcAmount: String
    var destAmount: String
    var userAddress: String
    var referrer: String = "moonkey"
}

struct GetTxResponse:Codable {
    var from: String?
    var to: String?
    var value: String?
    var data: String?
    var gasPrice: String?
    var gas: String?
    
    //Paraswap API return value as a String when swapping ETH and as Int when changing ERC20
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        from = try values.decode(String.self, forKey: .from)
        to = try values.decode(String.self, forKey: .to)
        data = try values.decode(String.self, forKey: .data)
        gasPrice = try values.decode(String.self, forKey: .gasPrice)
        gas = try values.decode(String.self, forKey: .gas)
        
        do {
            value = try values.decode(String.self, forKey: .value)
        } catch {
            value = "0"
        }
            
       }
    
}

class ParaswapService {
    
    let url = "https://api.paraswap.io/v2/"
    //let url = "https://api-ropsten.paraswap.io/api/v2/"
    let paraswapContract = "0x86969d29f5fd327e1009ba66072be22db6017cc6"
    let rpc = RpcClient()
    
    public func getTokens(completion: @escaping (Result<[Token], Error>) -> Void) -> Void {
        var request = URLRequest(url: URL(string: url+"tokens")!)
        request.httpMethod = "GET"
        
        Http.execute(with: request, receive: GetTokenResponse.self)  { (result) in
            switch result {
            case .success(let response):
                completion(.success(response.tokens))
                return
                
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }.resume()
    }
    
    public func getRate(sourceTokenAddress: String, destTokenAddress: String, amount: String, completion: @escaping (Result<PriceRoute, Error>) -> Void) -> Void {
        
        var request = URLRequest(url: URL(string:  url+"prices/?from="+sourceTokenAddress+"&to="+destTokenAddress+"&amount="+amount)!)
        request.httpMethod = "GET"
        
        print(request.url?.absoluteString)
        
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
        
        print("### REQUEST paraswap TX")
        print(String(data: request.httpBody!, encoding: .utf8)!)
        
        Http.execute(with: request, receive: GetTxResponse.self, completion: completion).resume()
    }
    
    public func getParaswapSenderAddress(completion: @escaping (Result<String, Error>) -> Void) -> Void {
        
        let function = Function(name: "getTokenTransferProxy", parameters: [])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [])
        
        let body = JSONRPCRequest(jsonrpc: "2.0", method: "eth_call", params: [["to":paraswapContract, "data":encoder.data.hexValue ]], id: 1)
        
        self.rpc.executeJSONRpc(with:body, receive: JSONRPCResult<String>.self) { (result) in
            switch result {
            case .success(let response):
                let strippedResult = response.result.replacingOccurrences(of: "0x000000000000000000000000", with: "0x")
                completion(.success(strippedResult))
                return
                
            case .failure(let error):
                completion(.failure(error))
                break
            }
        }.resume()
    }

}

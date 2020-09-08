//
//  ParaswapService.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 30/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation
import web3
import BigInt

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
    var multiRoute: [[Route]]?
    var bestRoute: [Route]
    var others: [OtherRoute]?
}

struct PriceRouteDetails: Codable {
    var tokenFrom: String?
    var tokenTo: String?
    var srcAmount: String?
    var routes: [String]?
}

/*amount: PriceString
 exchange: string
 percent: NumberAsString
 srcAmount: PriceString,
 data?: any,*/

class Route: Codable {
    var exchange: String
    var amount: String
    var srcAmount: String
    var percent: Int
    var data: RouteData?
}

/*exchange: string
 rate: NumberAsString
 unit: NumberAsString*/
class OtherRoute: Codable {
    var exchange: String
    var unit: String
    var rate: String
}

struct RouteData: Codable {
    var tokenFrom: String
    var tokenTo: String
    var exchange: String?
    var orders: [Order]?
    var path: [String]?
    var signatures: [String]?
    var networkFee: Int?
    var otc: String?
    var weth: String?
    var factory: String?
    var cToken: String?
    var aToken: String?
    var idleToken: String?
    var iToken: String?
    var i: Int?
    var j: Int?
    var deadline: Int?
    var underlyingSwap: Bool?
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
    
    
    let paraswapContract = web3.EthereumAddress("0x86969d29f5fd327e1009ba66072be22db6017cc6")
    
    var url: String {
        
        if Application.network == .mainnet {
            return "https://api.paraswap.io/v2/"
        }
        
        return "https://api-ropsten.paraswap.io/api/v2/"
    }
    
    public func getTokens(completion: @escaping (Result<[Token], Error>) -> Void) -> Void {
        var request = URLRequest(url: URL(string: url+"tokens/"+String(Application.network.ID))!)
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
        
        var request = URLRequest(url: URL(string:  url+"prices/?from="+sourceTokenAddress+"&to="+destTokenAddress+"&amount="+amount+"&excludeDEXS=0x&network="+String(Application.network.ID))!)
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
        var request = URLRequest(url: URL(string: url+"transactions/"+String(Application.network.ID))!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = body.toJSONData()
        
        Http.execute(with: request, receive: GetTxResponse.self, completion: completion).resume()
    }
    
    public func getParaswapSenderAddress(completion: @escaping (Result<web3.EthereumAddress, Error>) -> Void) -> Void {
        
        let function = GetTokenTransferProxyFunc(contract:paraswapContract )
        let transaction = try! function.transaction()
        
        Application.ethereumClient.eth_call(transaction) { (error, result) in
            
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let res = result else {
                completion(.failure(NSError(domain: "Nil result", code: 0, userInfo: nil)))
                return
            }
            let strippedResult = res.replacingOccurrences(of: "0x000000000000000000000000", with: "0x")
            completion(.success(web3.EthereumAddress(strippedResult)))
        }
    }
    
}

public struct GetTokenTransferProxyFunc: ABIFunction {
    public static let name = "getTokenTransferProxy"
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

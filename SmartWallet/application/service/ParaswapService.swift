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


/*export type OnChainOptimalRates = {
  amount: PriceString,
  bestRoute: Rate[],
  others?: OthersRate[]
};

export type OptimalRates = {
  amount: PriceString,
  bestRoute: Rate[],
  multiRoute?: Rate[][],
  others: OthersRate[],
  fromUSD?: string,
  toUSD?: string,
  details?:
    {
      tokenFrom: Address,
      tokenTo: Address,
      srcAmount: PriceString
    }
};*/

class PriceRoute: Codable {
    var amount: String
    var fromUSD: String
    var toUSD: String
    var details: PriceRouteDetails?
    var multiRoute: [[Route]]?
    var bestRoute: [Route]
    var others: [OtherRoute]?
}



/*{
  tokenFrom: Address,
  tokenTo: Address,
  srcAmount: PriceString
}*/

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


/*
 'makerAddress': 'address',           // Address that created the order.
 'takerAddress': 'address',           // Address that is allowed to fill the order. If set to 0, any address is allowed to fill the order.
 'feeRecipientAddress': 'address',   // Address that will recieve fees when order is filled.
 'senderAddress': 'address',          // Address that is allowed to call Exchange contract methods that affect this order. If set to 0, any address is allowed to call these methods.
 'makerAssetAmount': 'uint256',      // Amount of makerAsset being offered by maker. Must be greater than 0.
 'takerAssetAmount': 'uint256',       // Amount of takerAsset being bid on by maker. Must be greater than 0.
 'makerFee': 'uint256',               // Fee paid to feeRecipient by maker when order is filled.
 'takerFee': 'uint256',               // Fee paid to feeRecipient by taker when order is filled.
 'expirationTimeSeconds': 'uint256',  // Timestamp in seconds at which order expires.
 'salt': 'uint256',                   // Arbitrary number to facilitate uniqueness of the order's hash.
 'makerAssetData': 'bytes',           // Encoded data that can be decoded by a specified proxy contract when transferring makerAsset. The leading bytes4 references the id of the asset proxy.
 'takerAssetData': 'bytes',           // Encoded data that can be decoded by a specified proxy contract when transferring takerAsset. The leading bytes4 references the id of the asset proxy.
 'makerFeeAssetData': 'bytes',        // Encoded data that can be decoded by a specified proxy contract when transferring makerFeeAsset. The leading bytes4 references the id of the asset proxy.
 'takerFeeAssetData': 'bytes'
 */

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
    
 
    let paraswapContract = "0x86969d29f5fd327e1009ba66072be22db6017cc6"
    let rpc = RpcClient()
    
    
    var url: String {
        
        if Identity.chainID == 1 {
            return "https://api.paraswap.io/v2/"
        }
        
        return "https://api-ropsten.paraswap.io/api/v2/"
    }
    
    public func getTokens(completion: @escaping (Result<[Token], Error>) -> Void) -> Void {
        var request = URLRequest(url: URL(string: url+"tokens/"+String(Identity.chainID))!)
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
        
        var request = URLRequest(url: URL(string:  url+"prices/?from="+sourceTokenAddress+"&to="+destTokenAddress+"&amount="+amount+"&excludeDEXS=0x&network="+String(Identity.chainID))!)
        request.httpMethod = "GET"
        
        Http.execute(with: request, receive: GetRateResponse.self) { (result) in
            switch result {
            case .success(let response):
                completion(.success(response.priceRoute))
                return
                
            case .failure(let error):
                print("##### error rate")
                completion(.failure(error))
                return
            }
        }.resume()
    }
    
    public func getParaswapTx(body: GetTxRequest, completion: @escaping (Result<GetTxResponse, Error>) -> Void) -> Void {
        var request = URLRequest(url: URL(string: url+"transactions/"+String(Identity.chainID))!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = body.toJSONData()
        
        print(String(data:request.httpBody!, encoding: .utf8)!)
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

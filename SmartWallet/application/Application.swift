//
//  ApplicationContext.swift
//  SmartWallet
//
//  Created by Fred on 20/08/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation
import web3
import BigInt


public class Application {
    
    static public var smartwallet: SmartWallet?
    static public var account: HDEthereumAccount?
    static public var network: Chain = .mainnet
    static public var baseGas: BigUInt = BigUInt(70000)
    static public var ethPrice: Double?
    static public var tokenPrices: [String: [String: Double]]?
    
    
    //TODO should be returned from services
    static public var forwarderAddress: web3.EthereumAddress = web3.EthereumAddress("0x641d5315d213EA8eb03563f992c7fFfdd677D0cC")
    

    static public var rpc:RpcClient = RpcClient()
    
    static private var moonkeyService: MoonkeyService = MoonkeyService()
    static public var coinGeckoService: CoinGeckoService = CoinGeckoService()
    static public var etherscanService: EtherscanService = EtherscanService()
    
    static let ethereumClient: EthereumClient = EthereumClient(url: URL(string: "https://eth-mainnet.alchemyapi.io/v2/yKy-FkvOSlIgp9W8_mCxhW-HEdISZ7-Y")!)
    
    static let erc20: ERC20 = ERC20(client: ethereumClient)
    
    static func restore(walletId: WalletID){
        self.smartwallet = GnosisSafe(address: walletId.address, rpc: rpc)
        self.account = HDEthereumAccount(mnemonic: walletId.mnemonic)
    }
    
    static func clear(){
        self.smartwallet = nil
        self.account = nil
    }
    
    static func encodeExecute(to: web3.EthereumAddress, value:BigUInt, data: Data, safeTxGas: BigUInt, gasPrice: BigUInt = BigUInt(0), completion: @escaping (Result<(String), Error>) -> Void)  -> Void {
        self.smartwallet!.getTransactionHashWithNonce(to: to, value: value, data: data, safeTxGas: safeTxGas, baseGas: baseGas, gasPrice: gasPrice, refundReceiver: forwarderAddress) { (result) in
            switch result {
            case .success(let hash):
                let signature = self.account!.first.signV27(hash: Data(hex: hash)!)
                let executeData = self.smartwallet!.encodeExecute(to: to, value: value, data: data, safeTxGas: safeTxGas, baseGas: baseGas, gasPrice: gasPrice, refundReceiver: forwarderAddress, signature: signature)
                completion(.success(executeData))
                return
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
    }
    
    static func relay(to: web3.EthereumAddress, value:BigUInt, data: Data, safeTxGas: BigUInt, completion: @escaping (Result<(RelayResponse), Error>) -> Void)  -> Void {
        
        self.moonkeyService.getGasPrice() { (result) in
            switch result {
            case .success(let gasPriceResponse):
                let gasPrice = BigUInt(gasPriceResponse.gas_prices.fast)!
                
                self.encodeExecute(to: to, value: value, data: data, safeTxGas: safeTxGas, gasPrice:gasPrice) { (result) in
                    switch result {
                    case .success(let executeData):
                        
                        let gas = (safeTxGas + baseGas).description
                        print(gas)
                        self.moonkeyService.relayTransaction(smartWallet: Application.smartwallet!, messageData: executeData, completion: completion)
                        return
                    case .failure(let error):
                        completion(.failure(error))
                        return
                    }
                }
                return
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
    }
    
    static func updateTokensPrices(tokens: [TokenBalance], completion: @escaping (Result<(Bool), Error>) -> Void)  -> Void {
        self.coinGeckoService.getTokenPrices(tokens: tokens) { (result) in
            switch result {
            case .success(let tokenPrices):
                self.tokenPrices = tokenPrices
                completion(.success(true))
                break
            case .failure(let error):
                completion(.failure(error))
                break
            }
            
        }
    }
    
    static func updateEthPrice(completion: @escaping (Result<(Double), Error>) -> Void)  -> Void {
        self.etherscanService.ethPrice(){ (result) in
            switch result {
            case .success(let ethPrice):
                self.ethPrice = Double(ethPrice.ethusd)
                completion(.success(self.ethPrice!))
                return
            case .failure(let error):
                self.ethPrice = nil
                completion(.failure(error))
                return
            }
        }
    }
    
    static func calculateGasFees(safeGas: BigUInt, completion: @escaping (Result<(String), Error>) -> Void)  -> Void {
        guard let price = self.ethPrice else {
            completion(.failure(NSError(domain: "Error nill EthPrice", code: 0, userInfo: nil)))
            return
        }

        self.moonkeyService.getGasPrice() { (result) in
            switch result {
            case .success(let gasPriceResponse):
                let gasPrice = BigUInt(gasPriceResponse.gas_prices.fast)!
                
                let totalGas = safeGas + Application.baseGas
                let totalEth = totalGas * gasPrice
                
                let formatter = EtherNumberFormatter()
                let ethNumber = formatter.string(from:BigInt(totalEth))
                let ethDouble = Double(ethNumber)!
                
                let fees = ethDouble * price
       
                completion(.success("$"+String(format: "%.2f", fees)))
                return
                
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
        
        
        
    }
    
    static func isAccountOwner(completion: @escaping (Result<(Bool), Error>) -> Void)  -> Void {
        self.smartwallet?.isOwner(owner: web3.EthereumAddress(account!.first.ethereumAddress.value), completion: completion)
    }
    
    
}

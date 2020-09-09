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
    static public var baseGas: BigUInt = BigUInt(45000)
    static public var ethPrice: Double?
    static public var tokenPrices: [String: [String: Double]]?
    static public var gasPrices: Speeds?
    
    static public var backendService: BackendService = BackendService()
    static public var coinGeckoService: CoinGeckoService = CoinGeckoService()
    static public var etherscanService: EtherscanService = EtherscanService()
    
    static let ethereumClient: EthereumClient = EthereumClient(url: URL(string:infoForKey("RpcURL")! )!)
    
    static let erc20: ERC20 = ERC20(client: ethereumClient)
    
    static func restore(walletId: WalletID){
        self.smartwallet = GnosisSafe(address: walletId.address, rpc: ethereumClient)
        self.account = HDEthereumAccount(mnemonic: walletId.mnemonic)
    }
    
    static func clear(){
        self.smartwallet = nil
        self.account = nil
    }
    
    static func encodeExecute(to: web3.EthereumAddress, value:BigUInt, data: Data, safeTxGas: BigUInt, speed: Speed, completion: @escaping (Result<(String), Error>) -> Void)  -> Void {
        
        let gasPrice = BigUInt(speed.gas_price)!
        let refundAddress = EthereumAddress(speed.relayer)
        
        self.smartwallet!.getTransactionHashWithNonce(to: to, value: value, data: data, safeTxGas: safeTxGas, baseGas: baseGas, gasPrice:gasPrice , refundReceiver: refundAddress) { (result) in
            switch result {
            case .success(let hash):
                let signature = self.account!.first.signV27(hash: Data(hex: hash)!)
                let executeData = self.smartwallet!.encodeExecute(to: to, value: value, data: data, safeTxGas: safeTxGas, baseGas: baseGas, gasPrice: gasPrice, refundReceiver: refundAddress, signature: signature)
                completion(.success(executeData))
                return
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
    }
    
    static func relay(to: web3.EthereumAddress, value:BigUInt, data: Data, safeTxGas: BigUInt, completion: @escaping (Result<(RelayResponse), Error>) -> Void)  -> Void {
        
        Application.backendService.getGasPrice(address: self.smartwallet!.address) { (result) in
            switch result {
            case .success(let gasPriceResponse):
                
                self.encodeExecute(to: to, value: value, data: data, safeTxGas: safeTxGas, speed:gasPriceResponse.speeds.fastest) { (result) in
                    switch result {
                    case .success(let executeData):
                        
                        let gas = (safeTxGas + baseGas).description
                        print(gas)
                        Application.backendService.relayTransaction(smartWallet: Application.smartwallet!, messageData: executeData, completion: completion)
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
    
    static func updateGasPrice(completion: @escaping (Result<(Speeds), Error>) -> Void)  -> Void {
        self.backendService.getGasPrice(address: self.smartwallet!.address) { (result) in
            switch result {
            case .success(let gasPriceResponse):
                self.gasPrices = gasPriceResponse.speeds
                completion(.success(gasPriceResponse.speeds))
                break
                
            case .failure(let error):
                NSLog(error.localizedDescription)
                completion(.failure(error))
                break
            }
        }
    }
    
    static func calculateEtherForGas(safeGas: BigUInt) -> BigUInt {
        guard let gasPrices = self.gasPrices else {
            return BigUInt(0)
        }
        
        
        let gasPrice = BigUInt(gasPrices.fastest.gas_price)!
        let totalGas = safeGas + Application.baseGas
        let totalEth = totalGas * gasPrice
        
        return totalEth
    }
    
    static func calculateGasFees(safeGas: BigUInt)  -> String {
        
        guard let price = self.ethPrice else {
            return ""
        }
        
        let totalEth = calculateEtherForGas(safeGas: safeGas)
        
        let formatter = EtherNumberFormatter()
        let ethNumber = formatter.string(from:BigInt(totalEth))
        let ethDouble = Double(ethNumber.replacingOccurrences(of: ",", with: "."))!
        
        let fees = ethDouble * price
        
        return "$"+String(format: "%.2f", fees)
    }
    
    static func isAccountOwner(completion: @escaping (Result<(Bool), Error>) -> Void)  -> Void {
        self.smartwallet?.isOwner(owner: web3.EthereumAddress(account!.first.ethereumAddress.value), completion: completion)
    }
    
    
    
    static func infoForKey(_ key: String) -> String? {
        return (Bundle.main.infoDictionary?[key] as? String)?
            .replacingOccurrences(of: "\\", with: "")
    }
    
    
}

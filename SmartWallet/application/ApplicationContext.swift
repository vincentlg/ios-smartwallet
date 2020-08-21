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


public class ApplicationContext {
    
    static public var smartwallet: SmartWallet?
    static public var account: HDEthereumAccount?
    static public var network: Chain = .mainnet
    
    static func restore(walletId: WalletID){
        self.smartwallet = GnosisSafe(address: walletId.address, rpc: RpcClient())
        self.account = HDEthereumAccount(mnemonic: walletId.mnemonic)
    }
    
    static func clear(){
        self.smartwallet = nil
        self.account = nil
    }
    
    static func encodeExecute(to: web3.EthereumAddress, value:BigUInt, data: Data, completion: @escaping (Result<(String), Error>) -> Void)  -> Void {
        self.smartwallet!.getTransactionHashWithNonce(to: to, value: value, data: Data()) { (result) in
               switch result {
               case .success(let hash):
                   let signature = self.account!.first.signV27(hash: Data(hex: hash)!)
                   let executeData = self.smartwallet!.encodeExecute(to: to, value: value, data: Data(), signature: signature)
                   completion(.success(executeData))
            case .failure(let error):
                    completion(.failure(error))
                    return
                }
            }
        
    }
}

//
//  ApplicationContext.swift
//  SmartWallet
//
//  Created by Fred on 20/08/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation


public class ApplicationContext {
    
    static public var smartwallet: Identity?
    static public var account: HDEthereumAccount?
    static public var network: Chain = .mainnet
    
    static func restore(walletId: WalletID){
        self.smartwallet = Identity(address: EthereumAddress(string: walletId.address)!)
        self.account = HDEthereumAccount(mnemonic: walletId.mnemonic)
    }
    
    static func clear(){
        self.smartwallet = nil
        self.account = nil
    }
}

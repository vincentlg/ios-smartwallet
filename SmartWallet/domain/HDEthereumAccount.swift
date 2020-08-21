//
//  HDEthereumAccount.swift
//  SmartWallet
//
//  Created by Fred on 20/08/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation


public class HDEthereumAccount: HDWallet {
    
    convenience init() {
        let mnemonic = Crypto.generateMnemonic(strength: 128)
        self.init(mnemonic:mnemonic)
    }
    
    public func get(index: Int) -> PrivateKey {
        return self.getKey(at: Ethereum().derivationPath(at: index))
    }
    
    public var first: PrivateKey {
        self.get(index: 0)
    }
}

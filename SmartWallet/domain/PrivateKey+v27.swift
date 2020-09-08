//
//  PrivateKey+v27.swift
//  SmartWallet
//
//  Created by Fred on 21/08/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation


extension PrivateKey {
    
    public func signV27(hash: Data) -> Data {
        var signature = Crypto.sign(hash: hash, privateKey: data)
        let v = Int(signature[64])
     
        if (v < 27) {
            signature[64] +=  27
        }
        
        return signature
    }
}

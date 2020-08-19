//
//  PrivateKey+EthereumAddress.swift
//  WalletSdk
//
//  Created by Frederic DE MATOS on 24/02/2020.
//  Copyright © 2020 Rockside. All rights reserved.
//

import Foundation


extension PrivateKey {
    public var ethereumAddress: String {
        return self.publicKey().ethereumAddress.description
    }
}

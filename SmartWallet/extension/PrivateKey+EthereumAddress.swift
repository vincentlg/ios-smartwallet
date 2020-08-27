//
//  PrivateKey+EthereumAddress.swift
//  WalletSdk
//
//  Created by Frederic DE MATOS on 24/02/2020.
//  Copyright © 2020 Rockside. All rights reserved.
//

import Foundation
import web3

extension PrivateKey {
    public var ethereumAddress: web3.EthereumAddress {
        return web3.EthereumAddress(self.publicKey().ethereumAddress.description)
    }
}

//
//  Chain+Etherscan.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 11/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation
import RocksideWalletSdk

extension Chain {
    
    var etherscanAPIUrl: String {
        switch self {
        case .mainnet:
            return "https://api.etherscan.io/api"
        case .ropsten:
            return "https://api-ropsten.etherscan.io/api"
        case .poanetwork:
            return ""
        }
    }
    
}

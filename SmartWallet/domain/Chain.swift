//
//  Network.swift
//  WalletSdk
//
//  Created by Frederic DE MATOS on 25/02/2020.
//  Copyright © 2020 Rockside. All rights reserved.
//

import Foundation


public enum Chain {
    case mainnet, ropsten, poanetwork
    
    public var ID: Int {
        switch self {
        case .mainnet:
            return 1
        case .ropsten:
            return 3
        case .poanetwork:
            return 99
        }
    }
}

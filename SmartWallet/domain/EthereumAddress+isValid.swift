//
//  EthereumAddress+isValid.swift
//  SmartWallet
//
//  Created by Fred on 08/09/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation
import web3

public extension EthereumAddress {
    static func isValid(data: Data) -> Bool {
        return data.count == 20
    }

    /// Validates that the string is a valid address.
    static func isValid(string: String) -> Bool {
        guard let data = Data(hexString: string) else {
            return false
        }
        return EthereumAddress.isValid(data: data)
    }
}

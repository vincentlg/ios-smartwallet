//
//  File.swift
//  RocksideWalletSdk
//
//  Created by Frederic DE MATOS on 09/03/2020.
//  Copyright © 2020 Rockside. All rights reserved.
//

import Foundation
import BigInt

public extension BigInt {
    init?(hex: String) {
        let string: String
        if hex.hasPrefix("0x") {
            string = String(hex.dropFirst(2))
        } else {
            string = hex
        }
        
        self.init(string, radix: 16)
    }
}

public extension BigUInt {
    init?(hex: String) {
        let string: String
        if hex.hasPrefix("0x") {
            string = String(hex.dropFirst(2))
        } else {
            string = hex
        }
        
        self.init(string, radix: 16)
    }
}

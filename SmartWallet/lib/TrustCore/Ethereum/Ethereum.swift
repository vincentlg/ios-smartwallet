// Copyright © 2017-2018 Trust.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

/// Ethereum blockchain.
///
/// Ethereum-based blockchains should inherit from this class.
open class Ethereum: Blockchain {
    /// Chain identifier.
    open var chainID: Int {
        return 1
    }

    /// SLIP-044 coin type.
    open override var coinType: SLIP.CoinType {
        return .ethereum
    }
}



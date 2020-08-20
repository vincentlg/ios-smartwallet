//
//  IdentityTests.swift
//  WalletSdkTests
//
//  Created by Frederic DE MATOS on 21/02/2020.
//  Copyright © 2020 Rockside. All rights reserved.
//

import Foundation



import XCTest
import BigInt
import web3

@testable import Moonkey

class IdentityTests: XCTestCase {
    
    let mnemonic = "refuse pair extra viable drum account stand crazy domain holiday trend floor"
    let identityAddress = EthereumAddress(string: "0xeab90b8ebb9c05D3f288639d7E77eF415Ff5Febc")

    func testSignMessage() {
        let expectedSignature = "0x180a35430bab27b5eaf756fb5237a5fd7caf17daca03cf1f2fcc2fd85c393d776123a89bbed8d2faa1655b25b31dcb0b97ac71ebef6e1ee880a5f7aa2c22773a00"
              
        let identity = Identity(mnemonic:mnemonic, address: self.identityAddress!)
        
        let signature = identity.signTx(data: "", nonce: 0)
        XCTAssertEqual(signature, expectedSignature)
    }
    
    func testEncodeUpdateOwners() {
        let identity = Identity(mnemonic:mnemonic, address: self.identityAddress!)
        
        let messageData = identity.encodeUpdateWhiteList(eoa: "0xf845b2501A69eF480aC577b99e96796c2B6AE88E", value: true)
        XCTAssertEqual(messageData, "0x40b7e576000000000000000000000000f845b2501a69ef480ac577b99e96796c2b6ae88e0000000000000000000000000000000000000000000000000000000000000001")
    }
    
    func testEncodeExecuteWithData() {
        
        let identity = Identity(mnemonic:mnemonic, address: self.identityAddress!)
        
        let data = Data(hexString: "0xa9059cbb000000000000000000000000f845b2501a69ef480ac577b99e96796c2b6ae88e00000000000000000000000000000000000000000000000010a741a462780000")!
        let messageData = identity.encodeExecute(to: "0x6b175474e89094c44da98b954eedeac495271d0f", value: BigUInt(0), data: data)
        XCTAssertEqual(messageData, "0xb61d27f60000000000000000000000006b175474e89094c44da98b954eedeac495271d0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000044a9059cbb000000000000000000000000f845b2501a69ef480ac577b99e96796c2b6ae88e00000000000000000000000000000000000000000000000010a741a46278000000000000000000000000000000000000000000000000000000000000")
    }
    

}

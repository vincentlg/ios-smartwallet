//
//  KeyTests.swift
//  WalletTests
//
//  Created by Frederic DE MATOS on 18/02/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import XCTest


@testable import Moonkey

class EthereumAccountTests: XCTestCase {
    
    let privateKey = Crypto.hash("rockside".data(using: .utf8)!)

    func testInit() {
        
        let expectedPublicAddressString = "0xE8447B8D8f7Ad9499D085161B6613383fF77Eca8"
        let account = PrivateKey(data: privateKey)
        
        XCTAssertEqual(account?.ethereumAddress.value, expectedPublicAddressString.lowercased())
    }
    
    
    func testSign() {
        let expectedSignature = "0x24798d18b3ae057eef19a406f2c25f9c9224543ea66068ccb6281f1b07b480781e2703dc36c77c3f267a0afc8f66c2916a0ff801e64bdbd5d75632722754db9901"

        let account = PrivateKey(data: privateKey)
        let messageToSign = Crypto.hash("hello".data(using: .utf8)!)
        let signature = account?.sign(hash: messageToSign)
            
        XCTAssertEqual(signature!.hexValue, expectedSignature)
    }
 
}

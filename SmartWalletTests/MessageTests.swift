//
//  MessageTests.swift
//  WalletTests
//
//  Created by Frederic DE MATOS on 18/02/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation
import XCTest


@testable import Moonkey

class MessagesTests: XCTestCase {
    
    func testTxMessageHashWithEmptyData() {
        let expectedHash = "0xa6226f61e4d3ede4497e35949e79d997aed50f24f57bfd3361732e4d7475c6ba"
        
        let txMessage = TxMessage(signer: "0x2c68bfBc6F2274E7011Cd4AB8D5c0e69B2341309", to: "0x2c68bfBc6F2274E7011Cd4AB8D5c0e69B2341309", data: "", nonce: 0)
        
        let txMessageHash = txMessage.hash(chainID:3, verifyingContract:"0xeab90b8ebb9c05D3f288639d7E77eF415Ff5Febc")
        XCTAssertEqual(txMessageHash, expectedHash)
    }
    
    func testTxMessageHashWithData() {
        let expectedHash = "0x1f177092c4fbedf53f392389d4512f0a61babf07acc05303a4f1ef7e90b67d92"
        
        let txMessage = TxMessage(signer: "0x2c68bfBc6F2274E7011Cd4AB8D5c0e69B2341309", to: "0x68f3cEdf21B0f9ce31AAdC5ed110014Af5DA1828", data: "0xa21f3c6a68656c6c6f000000000000000000000000000000000000000000000000000000776f726c64202100000000000000000000000000000000000000000000000000", nonce: 0)
        
        let txMessageHash = txMessage.hash(chainID:3, verifyingContract:"0x9f733Fd052A5526cdc646E178c684B1Bf2313C57")
        XCTAssertEqual(txMessageHash, expectedHash)
        
    }
    
    func testTxMessageHashWithGasLimit() {
        let expectedHash = "0x1f177092c4fbedf53f392389d4512f0a61babf07acc05303a4f1ef7e90b67d92"
        
        let txMessage = TxMessage(signer: "0x2c68bfBc6F2274E7011Cd4AB8D5c0e69B2341309", to: "0x68f3cEdf21B0f9ce31AAdC5ed110014Af5DA1828", data: "0xa21f3c6a68656c6c6f000000000000000000000000000000000000000000000000000000776f726c64202100000000000000000000000000000000000000000000000000", nonce: 0)
        
        let txMessageHash = txMessage.hash(chainID:3, verifyingContract:"0x9f733Fd052A5526cdc646E178c684B1Bf2313C57")
        XCTAssertEqual(txMessageHash, expectedHash)
        
    }
    
    func testTxMessageHashWithGasPrice() {
        let expectedHash = "0x1f177092c4fbedf53f392389d4512f0a61babf07acc05303a4f1ef7e90b67d92"
        
        let txMessage = TxMessage(signer: "0x2c68bfBc6F2274E7011Cd4AB8D5c0e69B2341309", to: "0x68f3cEdf21B0f9ce31AAdC5ed110014Af5DA1828", data: "0xa21f3c6a68656c6c6f000000000000000000000000000000000000000000000000000000776f726c64202100000000000000000000000000000000000000000000000000", nonce: 0)
        
        let txMessageHash = txMessage.hash(chainID:3, verifyingContract:"0x9f733Fd052A5526cdc646E178c684B1Bf2313C57")
        XCTAssertEqual(txMessageHash, expectedHash)
        
    }
    
    
    
}

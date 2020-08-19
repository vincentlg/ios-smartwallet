//
//  RocksideTests.swift
//  WalletSdkTests
//
//  Created by Frederic DE MATOS on 25/02/2020.
//  Copyright © 2020 Rockside. All rights reserved.
//

import Foundation

import XCTest
import BigInt


class RocksideIntegrationTests: XCTestCase {
    
    /*static var rockside = Rockside(token:ProcessInfo.processInfo.environment["ROCKSIDE_KEY"]!, chain:.ropsten)
    
    func testDeployIdentity() {
        
        if (ProcessInfo.processInfo.environment["INTEGRATION_TEST"] == "true") {
            
            let expectation = self.expectation(description: "DeployIdentity")
            
            RocksideIntegrationTests.rockside.createIdentity{ (result) in
                switch result {
                case .success(let deployIdentityResponse):
                    XCTAssertEqual(66, deployIdentityResponse.transaction_hash.count)
                    XCTAssertEqual(42, RocksideIntegrationTests.rockside.identity!.eoa.ethereumAddress.count)
                    NSLog("### Identity address: "+RocksideIntegrationTests.rockside.identity!.ethereumAddress)
                    NSLog("### TXHas: "+deployIdentityResponse.transaction_hash)
                    XCTAssertEqual(42, RocksideIntegrationTests.rockside.identity!.ethereumAddress.count)
                    DispatchQueue.main.async {
                        _ = RocksideIntegrationTests.rockside.waitTxToBeMined(trackingID: deployIdentityResponse.tracking_id) { (result) in
                            switch result {
                            case .success(let receipt):
                                XCTAssertEqual(1, receipt.status)
                                expectation.fulfill()
                                break
                            case .failure(let error):
                                XCTFail("Unexpected error: \(error).")
                                expectation.fulfill()
                                break
                            }
                        }
                    }
                    break
                case .failure(let error):
                    XCTFail("Unexpected error: \(error).")
                    expectation.fulfill()
                    break
                }
            }
            
            waitForExpectations(timeout: 95, handler: nil)
        }
    }
    
    func testDeployIdentityWithBadKeyReturnError() {
        
        if (ProcessInfo.processInfo.environment["INTEGRATION_TEST"] == "true") {
            let expectation = self.expectation(description: "DeployIdentity")
            
            let rocksideWithBadToken = Rockside(token:"TOTO", chain:.ropsten, forwarder: "")
            rocksideWithBadToken.createIdentity{ (result) in
                switch result {
                case .success(_):
                    XCTFail("Should Fail")
                    expectation.fulfill()
                    break
                case .failure(let error):
                    XCTAssertEqual("The operation couldn’t be completed. (error http :401 - cannot parse token [TOTO] error 401.)", error.localizedDescription)
                    expectation.fulfill()
                    break
                }
            }
            waitForExpectations(timeout: 5, handler: nil)
        }
    }
    
    func testRelayTransaction(){
        
        if (ProcessInfo.processInfo.environment["INTEGRATION_TEST"] == "true") {
            
            let expectation = self.expectation(description: "RelayTransaction")
            
            RocksideIntegrationTests.rockside.identity!.relayTransaction(to: "0x2c68bfBc6F2274E7011Cd4AB8D5c0e69B2341309", value: "0", data: "0x", gas: "500000") { (result) in
                switch result {
                case .success(let response):
                    XCTAssertEqual(66, response.transaction_hash.count)
                    NSLog("### Txhash relay: "+response.transaction_hash)
                    DispatchQueue.main.async {
                        _ = RocksideIntegrationTests.rockside.waitTxToBeMined(trackingID: response.tracking_id) { (result) in
                            switch result {
                            case .success(let receipt):
                                XCTAssertEqual(1, receipt.status)
                                expectation.fulfill()
                                break
                            case .failure(let error):
                                XCTFail("Unexpected error: \(error).")
                                expectation.fulfill()
                                break
                            }
                        }
                    }
                    break
                case .failure(let error):
                    XCTFail("Unexpected error: \(error).")
                    expectation.fulfill()
                    break
                }
            }
            waitForExpectations(timeout: 120, handler: nil)
        }
        
    }
    
    func testRelayParams(){
        if (ProcessInfo.processInfo.environment["INTEGRATION_TEST"] == "true") {
            let expectation = self.expectation(description: "RelayTransaction")
            
            RocksideIntegrationTests.rockside.identity!.relayParams(){ (result) in
                switch result {
                case .success(let relayParams):
                    XCTAssertEqual(0, Int(relayParams.nonce))
                    XCTAssertNotEqual(0, relayParams.gas_prices.fast.count)
                     XCTAssertNotEqual(0, relayParams.gas_prices.fastest.count)
                     XCTAssertNotEqual(0, relayParams.gas_prices.standard.count)
                     XCTAssertNotEqual(0, relayParams.gas_prices.safelow.count)
                    expectation.fulfill()
                    break
                case .failure(let error):
                    XCTFail("Unexpected error: \(error).")
                    expectation.fulfill()
                    break
                }
            }
            waitForExpectations(timeout: 5, handler: nil)
        }
    }
    
    func testGetBalance(){
        if (ProcessInfo.processInfo.environment["INTEGRATION_TEST"] == "true") {
            let expectation = self.expectation(description: "RelayTransaction")
            
            RocksideIntegrationTests.rockside.identity!.getBalance(){ (result) in
                switch result {
                case .success(let balance):
                    XCTAssertEqual(BigInt(0), balance)
                    expectation.fulfill()
                    break
                case .failure(let error):
                    XCTFail("Unexpected error: \(error).")
                    expectation.fulfill()
                    break
                }
            }
            waitForExpectations(timeout: 5, handler: nil)
        }
    }
    
    
    func testTxReceipt(){
        if (ProcessInfo.processInfo.environment["INTEGRATION_TEST"] == "true") {
            let expectation = self.expectation(description: "TxReceipt")
            
            RocksideIntegrationTests.rockside.transactionStatus(trackingID: "01EBNV8K9WERG60DR8DXBTY517"){ (result) in
                switch result {
                case .success(let response):
                    guard let _ = response.receipt else {
                        XCTFail("Nil receipt")
                        expectation.fulfill()
                        break
                    }
                    XCTAssertEqual(response.receipt!.status, 1)
                    //XCTAssertEqual(response.receipt!.block_hash, "0xe3e8638f9a974a8d3f11c899746e0aa84ab896487cb2fabbdfd5e890e2a2878b")
                    //XCTAssertEqual(response.receipt!.block_number, 8023190)
                    //XCTAssertEqual(response.status, "success")
                    expectation.fulfill()
                    break
                case .failure(let error):
                    XCTFail("Unexpected error: \(error).")
                    expectation.fulfill()
                    break
                }
            }
            waitForExpectations(timeout: 5, handler: nil)
        }
    }
    
    func testERC20Balance(){
        if (ProcessInfo.processInfo.environment["INTEGRATION_TEST"] == "true") {
            let expectation = self.expectation(description: "ERC20Balance")
            
            RocksideIntegrationTests.rockside.identity!.getErc20Balance(ercAddress: "0x5d538965d0c5f2c21aabf16a24367fb37692cae3") { (result) in
                switch result {
                case .success(let balance):
                    XCTAssertEqual(balance.description, "0")
                    expectation.fulfill()
                    break
                case .failure(let error):
                    XCTFail("Unexpected error: \(error).")
                    expectation.fulfill()
                    break
                }
            }
            waitForExpectations(timeout: 5, handler: nil)
        }
    }
    
    
    func testUpdateWhiteListAndIsEOAWhiteListed() {
        
        if (ProcessInfo.processInfo.environment["INTEGRATION_TEST"] == "true") {
            let expectation = self.expectation(description: "isEOAWhiteListed")
            
            let eoaToWhitelist = "0xf845b2501A69eF480aC577b99e96796c2B6AE88E"
            RocksideIntegrationTests.rockside.identity!.updateWhiteList(eoa: eoaToWhitelist, value: true) { (result) in
                switch result {
                    case .success(let response):
                        XCTAssertEqual(66, response.transaction_hash.count)
                        NSLog("### Txhash whitelist: "+response.transaction_hash)
                        DispatchQueue.main.async {
                            _ = RocksideIntegrationTests.rockside.waitTxToBeMined(trackingID: response.tracking_id) { (result) in
                                switch result {
                                case .success(let receipt):
                                    XCTAssertEqual(receipt.status, 1)
                                    RocksideIntegrationTests.rockside.identity!.isEOAWhiteListed(eoa: eoaToWhitelist) { (result) in
                                        switch result {
                                        case .success(let result):
                                            XCTAssertEqual(result, true)
                                            expectation.fulfill()
                                            break
                                            
                                        case .failure(let error):
                                            XCTFail("Unexpected error: \(error).")
                                            expectation.fulfill()
                                            break
                                        }
                                    }
                                    break
                                case .failure(let error):
                                    XCTFail("Unexpected error: \(error).")
                                    expectation.fulfill()
                                    break
                                }
                            }
                        }
                        
                        
                        break
                        
                    case .failure(let error):
                        XCTFail("Unexpected error: \(error).")
                        expectation.fulfill()
                        break
                    }
                }
            waitForExpectations(timeout: 120, handler: nil)
        }
        
    }*/
    
    
    
}

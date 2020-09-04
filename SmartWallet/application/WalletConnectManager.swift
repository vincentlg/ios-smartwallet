//
//  WalletConnectManager.swift
//  SmartWallet
//
//  Created by Fred on 01/09/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation
import WalletConnect
import BigInt
import web3

class WalletConnectManager{
    
    static var sessionMeta: WCPeerMeta?
    static let meta: WCPeerMeta =  WCPeerMeta(name: "MoonKey", url: "https://rockside.io")
    static var interactor: WCInteractor?
    
    static var presenter: ((_: WCPeerMeta, _: String, _: String, _: String?) -> Void)?
    
    static var requestTx: WCEthereumTransaction?
    static var requestID: Int64?
    
    
    static func createSession(scannedCode: String, presentFunction: @escaping ((_: WCPeerMeta, _: String, _: String, _: String?) -> Void)){
        
        guard let session = WCSession.from(string: scannedCode) else {
            return
        }
        
        self.presenter = presentFunction
        
        let interactor = WCInteractor(session: session, meta: meta, uuid:  UIDevice.current.identifierForVendor ?? UUID(), sessionRequestTimeout: 60)
        
        
        configure(interactor: interactor)
        
        interactor.connect().done { connected in
            NSLog("####### connect success")
            
        }.catch { error in
            NSLog("####### connect Error")
        }
        
        self.interactor = interactor
    }
    
    static func configure(interactor: WCInteractor) {
        interactor.onError = { error in
            NSLog("####### interacton On Error")
        }
        
        interactor.onSessionRequest = { (id, peerParam) in
            self.sessionMeta = peerParam.peerMeta
            self.presenter!(self.sessionMeta!, "Wants to connect your wallet",
                            " • Access balance and history\n • Request transaction approval", nil)
        }
        
        interactor.onDisconnect = { (error) in
            NSLog("####### on disconnect")
            if let error = error {
                print(error)
                // TODO "Ask to reconnecr"
                interactor.resume()
            }
        }
        
        interactor.eth.onSign = {(id, payload) in
            NSLog("####### on eth Sign")
        }
        
        interactor.eth.onTransaction = { (id, event, transaction) in
            NSLog(transaction.toJSONString()!)
            
            let value = BigInt(hex: transaction.value!)!
            let formatter = EtherNumberFormatter()
            var ethNumber = formatter.string(from: value)
            ethNumber = String(format: "%.3f", (ethNumber.replacingOccurrences(of: ",", with: ".") as NSString).floatValue)
            
            self.requestTx = transaction
            self.requestID = id
            
            self.presenter!(self.sessionMeta!, "Approve transaction",
                            "Value: "+ethNumber+" ETH", transaction.gas)
        }
    }
    
    static public func rejectHandler() -> Void {
        
        if self.requestTx == nil {
            self.interactor?.rejectSession().cauterize()
        } else {
            self.interactor?.rejectRequest(id: self.requestID!, message: "Request rejected.").cauterize()
        }
     }
     
     static public func approveHandler() -> Void {
        if self.requestTx == nil {
            self.interactor?.approveSession(accounts:  [Application.smartwallet!.address.value],
                                        chainId: Application.network.ID).cauterize()
        } else {
            let data = Data(hexString: self.requestTx!.data)!
            let gas = BigUInt(hex: self.requestTx!.gas!)!
            let value = BigUInt(hex: self.requestTx!.value!)!
            
            Application.relay(to: web3.EthereumAddress(self.requestTx!.to!), value: value,
                              data: data, safeTxGas:gas) { (result) in
                switch result {
                case .success(let txResponse):
                    self.interactor!.approveRequest(id: self.requestID!, result: txResponse.transaction_hash).cauterize()
                    break
                    
                case .failure(_):
                    self.interactor?.rejectRequest(id: self.requestID!, message: "An error occured.").cauterize()
                    break
                }
            }
        }
     }
    
 
    
    
}

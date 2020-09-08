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
    
    static let meta: WCPeerMeta =  WCPeerMeta(name: "MoonKey", url: "https://rockside.io")
    
    static var interactor: WCInteractor?
    static var sessionMeta: WCPeerMeta?
    
    static var requestTx: WCEthereumTransaction?
    static var requestID: Int64?
    
    static var presenter: ((_: WCPeerMeta, _: String, _: String, _: String?) -> Void)?
    
    static func createSession(scannedCode: String, presentFunction: @escaping ((_: WCPeerMeta, _: String, _: String, _: String?) -> Void)){
        
        guard let session = WCSession.from(string: scannedCode) else {
            return
        }
        
        self.presenter = presentFunction
        
        let interactor = WCInteractor(session: session, meta: meta, uuid:  UIDevice.current.identifierForVendor ?? UUID(), sessionRequestTimeout: 360)
        
        
        interactor.onError = { error in
            NSLog("Interactor on Error: \(error.localizedDescription)")
        }
        
        interactor.onSessionRequest = { (id, peerParam) in
            self.sessionMeta = peerParam.peerMeta
            self.presenter!(self.sessionMeta!, "Wants to connect your wallet",
                            " • Access balance and history\n • Request transaction approval", nil)
        }
        
        interactor.onDisconnect = { (error) in
            NSLog("Interactor disconnected")
            if let error = error {
                NSLog("Interactor on disconnect: \(error.localizedDescription)")
                // TODO "Ask to reconnecr"
                //interactor.resume()
                self.cleanRequest()
                self.cleanSession()
            }
        }
        
        interactor.eth.onTransaction = { (id, event, transaction) in
            let value = BigInt(hex: transaction.value!)!
            let formatter = EtherNumberFormatter()
            var ethNumber = formatter.string(from: value)
            ethNumber = String(format: "%.3f", (ethNumber.replacingOccurrences(of: ",", with: ".") as NSString).floatValue)
            
            self.requestTx = transaction
            self.requestID = id
            
            self.presenter!(self.sessionMeta!, "Approve transaction", "Value: "+ethNumber+" ETH", transaction.gas)
        }
        
        interactor.connect().done { _ in }.catch { error in
            self.cleanSession()
        }
        
        self.interactor = interactor
    }
    
    
    static public func rejectHandler() -> Void {
        
        if self.requestTx == nil {
            self.interactor?.rejectSession().cauterize()
        } else {
            self.interactor?.rejectRequest(id: self.requestID!, message: "Request rejected.").cauterize()
            self.cleanRequest()
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
                                    self.cleanRequest()
                                    break
                                    
                                case .failure(_):
                                    self.interactor?.rejectRequest(id: self.requestID!, message: "An error occured.").cauterize()
                                    self.cleanRequest()
                                    break
                                }
            }
        }
    }
    
    static private func cleanRequest() -> Void {
        self.requestID = nil
        self.requestTx = nil
    }
    
    static private func cleanSession() -> Void {
        self.sessionMeta = nil
        self.interactor = nil
    }
    
    static func willEnterBackground() {
        if (self.interactor?.state == .connected){
            NSLog("PAUSE")
            self.interactor?.pause()
        }
    }
    
    static func willEnterForeground(){
        if (self.interactor?.state == .paused){
            self.interactor?.resume()
        }
    }
}

//
//  WalletConnectManager.swift
//  SmartWallet
//
//  Created by Fred on 01/09/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation
import WalletConnect

class WalletConnectManager{
    
    static var session: WCSession?
    static let meta: WCPeerMeta =  WCPeerMeta(name: "MoonKey", url: "https://rockside.io")
    static var interactor: WCInteractor?
    
    static var presenter: ((_: WCSessionRequestParam, _: String) -> Void)?
    
    
    static func createSession(scannedCode: String, presentFunction: @escaping ((_: WCSessionRequestParam, _: String) -> Void)){
        
        NSLog(scannedCode)
        guard let session = WCSession.from(string: scannedCode) else {
            return
        }
        
        self.session = session
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
        let accounts = [Application.smartwallet!.address.value]
        let chainId = 1
        
        interactor.onError = { error in
            NSLog("####### interacton On Error")
        }
        
        interactor.onSessionRequest = { (id, peerParam) in
            
            NSLog("####### on session Request")
            self.presenter!(peerParam, "Hello")
            self.interactor!.approveSession(accounts: accounts, chainId: chainId).cauterize()
            
            
            //self.show(alert, sender: nil)
        }
        
        interactor.onDisconnect = { (error) in
            NSLog("####### on disconnect")
            if let error = error {
                print(error)
                // TODO "Ask to reconnecr"
                interactor.resume()
            }
        }
        
        interactor.bnb.onSign = { [self] (id, order) in
            NSLog("####### on BNB Sign")
        }
        interactor.eth.onSign = { [self] (id, payload) in
            NSLog("####### on eth Sign")
        }
        
        interactor.eth.onTransaction = { (id, event, transaction) in
            NSLog("####### on eth TX")
            NSLog(transaction.toJSONString()!)
         
            /*let data = try! JSONEncoder().encode(transaction)
             let message = String(data: data, encoding: .utf8)
             let alert = UIAlertController(title: event.rawValue, message: message, preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "Reject", style: .destructive, handler: { _ in
             self.interactor?.rejectRequest(id: id, message: "I don't have ethers").cauterize()
             }))*/
            //self?.show(alert, sender: nil)
        }
        
        
        
    }
    
    
}

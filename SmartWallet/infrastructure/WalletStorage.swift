//
//  KeyStorage.swift
//  RocksideWalletSdk
//
//  Created by Frederic DE MATOS on 07/04/2020.
//  Copyright © 2020 Rockside. All rights reserved.
//

import Foundation
import KeychainAccess

let identityStorageIDKey = "identity_id_key"

struct WalletID: Codable {
    var address: String
    var mnemonic: String
}

public enum WalletStorageError: Error {
    case notFound
    case failedToEncode
    case failedToDecode
    case failedToLoad
}

struct WalletStorage {
    
    private let keychain = Keychain()
    
    public func store(walletID: WalletID) throws {
       
        guard let jsonString = walletID.toJSONString() else{
            throw WalletStorageError.failedToEncode
        }
        
        try self.keychain.set(jsonString, key:identityStorageIDKey)
    }
    
    public func clear() throws {
        try keychain.remove(identityStorageIDKey)
    }
    
    public func retrieve() throws -> WalletID  {
        guard let jsonString = try self.keychain.get(identityStorageIDKey) else {
            throw WalletStorageError.notFound
        }
        
        guard let jsonData = jsonString.data(using: .utf8) else {
             throw WalletStorageError.failedToDecode
        }
        
        return try JSONDecoder().decode(WalletID.self, from:jsonData)
    }
    
}

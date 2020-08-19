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

struct IdentityID: Codable {
    var address: String
    var mnemonic: String
}

public enum IdentityStorageError: Error {
    case notFound
    case failedToEncode
    case failedToDecode
    case failedToLoad
}

struct IdentityStorage {
    
    private let keychain = Keychain()
    
    public func store(identity: Identity) throws {
        let identityID = IdentityID(address: identity.ethereumAddress, mnemonic: identity.hdwallet.mnemonic)
        guard let jsonString = identityID.toJSONString() else{
            throw IdentityStorageError.failedToEncode
        }
        
        try self.keychain.set(jsonString, key:identityStorageIDKey)
    }
    
    public func clear() throws {
        try keychain.remove(identityStorageIDKey)
    }
    
    public func retrieve() throws -> IdentityID  {
        guard let jsonString = try self.keychain.get(identityStorageIDKey) else {
            throw IdentityStorageError.notFound
        }
        
        guard let jsonData = jsonString.data(using: .utf8) else {
             throw IdentityStorageError.failedToDecode
        }
        
        return try JSONDecoder().decode(IdentityID.self, from:jsonData)
    }
    
}

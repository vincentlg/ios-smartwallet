//
//  Encodable+ToJSONData.swift
//  WalletSdk
//
//  Created by Frederic DE MATOS on 25/02/2020.
//  Copyright © 2020 Rockside. All rights reserved.
//

import Foundation

public extension Encodable {
    func toJSONData() -> Data? { try? JSONEncoder().encode(self) }
    
    func toJSONString() -> String?{
        
        guard let jsonData = self.toJSONData() else {
            return nil
        }
        
        return String(data:jsonData, encoding: .utf8 )
    }
    
}

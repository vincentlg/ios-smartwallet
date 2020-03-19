//
//  TokenBalanceViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 19/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import RocksideWalletSdk

typealias TokenBalanceSelectionHandler = (_: TokenBalance) -> Void

class TokenBalanceTableViewController: UITableViewController {

    var tokens: [TokenBalance]?
    
    var selectionHandler: TokenBalanceSelectionHandler?
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.tokens != nil else {
            return 0
        }
        
        return self.tokens!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokenBalanceViewCell", for: indexPath)
        cell.textLabel?.text = self.tokens![indexPath.row].symbol
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectionHandler!(self.tokens![indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
    
   
}

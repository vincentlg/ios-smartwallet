//
//  TokensTableViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 13/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit


typealias TokenSelectionHandler = (_: Token) -> Void

class TokensTableViewController: UITableViewController {
    
    var tokens: [Token]?
    
    var selectionHandler: TokenSelectionHandler?
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokenViewCell", for: indexPath)
        cell.textLabel?.text = self.tokens![indexPath.row].symbol
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectionHandler!(self.tokens![indexPath.row])
    }
    
}

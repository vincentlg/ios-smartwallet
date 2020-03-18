//
//  BalanceViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 11/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit

class BalanceViewContrller: UITableViewController{
    
    var tokenBalances: [TokenBalance] = []
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tokenBalances.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BalanceViewCell", for: indexPath) as! BalanceViewCell
        cell.display(balance: tokenBalances[indexPath.row])
        return cell
    }
    
    public func display(balances: [TokenBalance]) {
        self.tokenBalances = balances
        self.tableView.reloadData()
    }
    
}

//
//  File.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 11/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit


class TransactionViewContrller: UITableViewController{
    
    var transactions: [Transaction] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()
        let safeAreaBottom: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: safeAreaBottom, right: 0.0)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionViewCell", for: indexPath) as! TransactionViewCell
        cell.display(transaction: transactions[indexPath.row])
        return cell
    }
    
    public func display(transactions: [Transaction] ) {
        self.transactions = transactions
        self.tableView.reloadData()
    }
}

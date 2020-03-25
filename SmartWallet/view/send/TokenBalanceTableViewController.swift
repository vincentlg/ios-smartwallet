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

class TokensSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tokens: [TokenBalance]?
    
    @IBOutlet weak var tokenBalanceTableView: UITableView!
    
    var selectionHandler: TokenBalanceSelectionHandler?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tokenBalanceTableView.dataSource = self
        self.tokenBalanceTableView.delegate = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.tokens != nil else {
            return 0
        }
        
        return self.tokens!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BalanceViewCell", for: indexPath) as! BalanceViewCell
        cell.display(balance: self.tokens![indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectionHandler!(self.tokens![indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
    
   
}

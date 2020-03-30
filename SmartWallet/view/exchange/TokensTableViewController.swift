//
//  TokensTableViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 13/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit


typealias TokenSelectionHandler = (_: Token) -> Void

class TokensTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tokens: [Token]?
    
    var selectionHandler: TokenSelectionHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokenViewCell", for: indexPath) as! TokenTableViewCell
        cell.display(token:self.tokens![indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectionHandler!(self.tokens![indexPath.row])
    }
    
}

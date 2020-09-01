//
//  OwnersViewControllers.swift
//  SmartWallet
//
//  Created by Fred on 24/08/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialSnackbar

class OwnersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var owners: [String] = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.refreshOwner()
    }
    
    func refreshOwner() {
        Application.smartwallet?.getOwners() { (result) in
            switch result {
            case .success(let owners):
                DispatchQueue.main.async {
                    self.owners = owners
                    self.tableView.reloadData()
                }
                return
                
            case .failure(_):
                DispatchQueue.main.async {
                   let snackBarMessage = MDCSnackbarMessage()
                   snackBarMessage.text = "An error occured. Please try again."
                  MDCSnackbarManager.default.show(snackBarMessage)
                }
                return
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return owners.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OwnerViewCell", for: indexPath) as! OwnerTableViewCell
        cell.display(address: self.owners[indexPath.row])
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addowner_segue" {
            if let destinationVC = segue.destination as? AddOwnerViewController {
                destinationVC.successHandler = self.refreshOwner
            }
        }
    }
    
    
    
}

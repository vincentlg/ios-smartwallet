//
//  SettingsViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 08/04/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit



struct ItemSettings{
    var label: String
    var iconName: String
    var action: () -> Void
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let walletStorage: WalletStorage = WalletStorage()
        
    let sections = ["Security", "Contact"]
    var securityItems: [ItemSettings] = []
    var contactItems: [ItemSettings] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        self.securityItems = [ItemSettings(label: "Recovery kit", iconName: "shield", action:self.showRecovery), ItemSettings(label: "Wallet owners", iconName: "award", action: self.showOwners), ItemSettings(label: "Reset wallet", iconName: "alert-circle", action: self.resetWalletWarning)]
        self.contactItems = [ItemSettings(label: "Rockside", iconName: "twitter", action: self.showRocksideTwitter), ItemSettings(label: "Paraswap", iconName: "twitter", action: showParaswapTwitter)]
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear

        let sectionLabel = UILabel(frame: CGRect(x: 30, y: 28, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        sectionLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        sectionLabel.textColor = UIColor.link
        sectionLabel.text = self.sections[section]
        sectionLabel.sizeToFit()
        headerView.addSubview(sectionLabel)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40  // or whatever
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return securityItems.count
        }
        return contactItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsViewCell", for: indexPath) as! SettingsViewCell
        
        cell.display(item:  getItem(indexPath: indexPath))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        getItem(indexPath: indexPath).action()
    }
    
    func getItem(indexPath: IndexPath) -> ItemSettings {
        let item: ItemSettings
               
        if indexPath.section == 0 {
            item = securityItems[indexPath.row]
        } else {
            item = contactItems[indexPath.row]
        }
        
        return item
    }
    
    func showRecovery() {
        self.performSegue(withIdentifier: "show_recovery_segue", sender: self)
    }
    
    func showOwners() {
        self.performSegue(withIdentifier: "show_owners", sender: self)
    }
    
    func showRocksideTwitter() {
        UIApplication.shared.open(URL(string: "https://twitter.com/rockside_io")!, options: [:], completionHandler: nil)
    }
    
    func showParaswapTwitter() {
        UIApplication.shared.open(URL(string: "https://twitter.com/paraswap")!, options: [:], completionHandler: nil)
    }
    
    func resetWalletWarning() {
        let ac = UIAlertController(title: "Warning", message: "You are going to reset your Wallet.\n\n If you did not backed up you wallet address and your recovery phrase, you will loose all your assets !", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Reset", style: .default) { _ in self.reallySure() })
        self.present(ac, animated: true)
       }
    
    func reallySure() {
        let ac = UIAlertController(title: "Warning", message: "Are you really sure you want to reset your wallet", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Reset", style: .default){ _ in  self.resetWallet()})
        self.present(ac, animated: true)
    }
    
    func resetWallet() {
         do {
            try self.walletStorage.clear();
            if let navController = self.navigationController {
                self.dismiss(animated: true, completion: nil)
                navController.displayNoWalletView()
            }
        } catch {
            let ac = UIAlertController(title: "Error", message: "Unable to reset your wallet.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(ac, animated: true)
            return
        }
        
    }
    
    
    
    
}

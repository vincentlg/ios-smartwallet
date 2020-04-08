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
    
    let sections = ["Security", "Contact"]
    var securityItems: [ItemSettings] = []
    var contactItems: [ItemSettings] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        self.securityItems = [ItemSettings(label: "Recovery kit", iconName: "shield", action:self.showRecovery), ItemSettings(label: "Whitelist address", iconName: "award", action: self.showWhitelist)]
        self.contactItems = [ItemSettings(label: "Follow Rockside", iconName: "twitter", action: self.showRocksideTwitter), ItemSettings(label: "Follow Paraswap", iconName: "twitter", action: showParaswapTwitter)]
        
        
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
        
       
        let item = getItem(indexPath: indexPath)
        cell.itemLabel.text = item.label
        cell.itemImageView.image = UIImage(named: item.iconName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = getItem(indexPath: indexPath)
        item.action()
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
    
    func showWhitelist() {
        self.performSegue(withIdentifier: "add_whitelist_segue", sender: self)
    }
    
    func showRocksideTwitter() {
        UIApplication.shared.open(URL(string: "https://twitter.com/rockside_io")!, options: [:], completionHandler: nil)
    }
    
    func showParaswapTwitter() {
        UIApplication.shared.open(URL(string: "https://twitter.com/paraswap")!, options: [:], completionHandler: nil)
    }
    
    
    
    
}

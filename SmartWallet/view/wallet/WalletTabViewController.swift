//
//  WalletTabViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 11/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import RocksideWalletSdk
import BigInt

struct EtherscanTransactionResponse: Codable{
    var status: String
    var message: String
    var result: [Transaction]
}

struct EtherscanTokenBalanceResponse: Codable{
    var status: String
    var message: String
    var result: String
}


typealias BalanceUpdatedHandler = () -> Void

class WalletTabViewController: TabmanViewController {
    
    private var viewControllers: [UIViewController]?
    
    private var etherscanApiKey = "HCYC8QMVAN8M5RSMKWT7FFGG2KTU1N3IVG"
    
    private let etherFormatter = EtherNumberFormatter()
    
    var balanceUpdatedHandler:BalanceUpdatedHandler?
    var tokenBalances:[String : TokenBalance] = ["ETH": TokenBalance(name: "Ethereum", symbol: "ETH")]
    var transactions: [Transaction] = []
    
    
    private var balanceViewController: BalanceViewContrller?
    private var transactionViewController: TransactionViewContrller?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.balanceViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BalanceViewController") as? BalanceViewContrller
        
        self.transactionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as? TransactionViewContrller
        
        self.viewControllers = [self.balanceViewController!, self.transactionViewController!]
        
        self.dataSource = self
        
        let bar =  TMBarView<TMConstrainedHorizontalBarLayout, TMLabelBarButton, TMBarIndicator.None>()
        bar.layout.transitionStyle = .snap // Customize
        
        // Add to view
        addBar(bar, dataSource: self, at: .top)
        
        self.retriveAllTransactions()
    }
    
    public func retriveAllTransactions() {
        self.transactions = []
        retrieveTransaction(action: "txlist")
        retrieveTransaction(action: "txlistinternal")
        retrieveTransaction(action: "tokentx")
    }
    
    private func retrieveTransaction(action: String) {
        
        let url  = URL(string: "\(self.rockside.chain.etherscanAPIUrl)?module=account&action=\(action)&address=\(self.rockside.identity!.ethereumAddress)&startblock=0&endblock=99999999&sort=desc&apikey=\(etherscanApiKey)")!
        
        var request = URLRequest(url:url ,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            
            let decoder = JSONDecoder()
            let response = try! decoder.decode(EtherscanTransactionResponse.self, from: data)
            DispatchQueue.main.async {
                self.transactions.append(contentsOf: response.result)
                
                self.transactions = self.transactions.filter{ $0.type != "Relay" }
                
                self.transactions.sort {
                    $0.block > $1.block
                }
                
                self.transactionViewController?.display(transactions: self.transactions)
                
                if (action == "tokentx") {
                    self.updateBalance()
                }
            }
        }
        
        task.resume()
        
        
    }
    
    private func getEthBalance() {
        self.rockside.getBalance() { (result) in
            switch result {
            case .success(let balance):
                DispatchQueue.main.async {
                    let balanceString = self.etherFormatter.string(from: balance)
                    self.tokenBalances["ETH"]?.balance = balanceString
                    self.balanceViewController?.display(balances: Array<TokenBalance>(self.tokenBalances.values))
                    
                    self.balanceUpdatedHandler?()
                }
                
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    private func get(tokenBalance: TokenBalance) {
        let url  = URL(string: "\(self.rockside.chain.etherscanAPIUrl)?module=account&action=tokenbalance&address=\(self.rockside.identity!.ethereumAddress)&contractaddress=\(tokenBalance.address!)&tag=lates&apikey=\(etherscanApiKey)")!
        
        var request = URLRequest(url:url ,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            
            let decoder = JSONDecoder()
            let response = try! decoder.decode(EtherscanTokenBalanceResponse.self, from: data)
            DispatchQueue.main.async {
                let balanceString = self.etherFormatter.string(from: BigInt(response.result)!)
                self.tokenBalances[tokenBalance.symbol]?.balance = balanceString
                self.balanceViewController?.display(balances: Array<TokenBalance>(self.tokenBalances.values))
            }
        }
        
        task.resume()
    }
    
    private func updateBalance() {
        self.transactions.forEach {
            if $0.isERC {
                self.tokenBalances[$0.tokenSymbol!] =  TokenBalance(name: $0.tokenName!, symbol: $0.tokenSymbol!, address: $0.contractAddress)
            }
        }
        for (symbol, balance) in self.tokenBalances {
            
            if (symbol == "ETH") {
                self.getEthBalance()
            } else {
                self.get(tokenBalance: balance)
            }
            
        }
    }
    
    override func pageboyViewController(_ pageboyViewController: PageboyViewController, willScrollToPageAt index: Int, direction: NavigationDirection, animated: Bool) {
        super.pageboyViewController(pageboyViewController, willScrollToPageAt: index, direction: direction, animated: animated)
        
        if (index == 1) {
            self.retriveAllTransactions()
        }
           
    }
    
}

extension WalletTabViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        
        var title: String = ""
        
        if index == 0 {
            title = "Balance"
        } else if index == 1 {
            title = "Transactions"
        }
        
        let item = TMBarItem(title: title)
        return item
    }
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers!.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers![index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
    
   
    
}

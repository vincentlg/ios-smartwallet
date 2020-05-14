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
import JGProgressHUD

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
typealias RefreshHandler = () -> Void

class WalletTabViewController: TabmanViewController {
    
    private var viewControllers: [UIViewController]?
    private var etherscanApiKey = "HCYC8QMVAN8M5RSMKWT7FFGG2KTU1N3IVG"

    private var balanceViewController: BalanceViewContrller?
    private var transactionViewController: TransactionViewContrller?
    
    var balanceUpdatedHandler: BalanceUpdatedHandler?
    var tokenBalances:[String : TokenBalance] = ["ETH": TokenBalance(name: "Ethereum", symbol: "ETH")]
    
    var displayErrorHandler: DisplayErrorHandler?
    
    var transactions: [Transaction] = []
    var transactionsBuffer: [Transaction] = []
    var transactionCallRetrieved:Int = 0
    
    let hud = JGProgressHUD(style: .light)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.balanceViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BalanceViewController") as? BalanceViewContrller
        
        self.balanceViewController?.refreshHandler = self.retriveAllTransactions
        
        self.transactionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as? TransactionViewContrller
        
        self.transactionViewController?.refreshHandler = self.retriveAllTransactions
        
        self.viewControllers = [self.balanceViewController!, self.transactionViewController!]
        
        self.dataSource = self
        self.retriveAllTransactions()
    }
    
    public func retriveAllTransactions() {
        
        if (transactions.count == 0) {
            DispatchQueue.main.async {
                self.hud.show(in: self.view)
            }
        }
        
        self.transactionsBuffer = []
        self.transactionCallRetrieved = 0
        retrieveTransaction(action: "txlist")
        retrieveTransaction(action: "txlistinternal")
        retrieveTransaction(action: "tokentx")
        
    }
    
    private func retrieveTransaction(action: String) {
        
        let url  = URL(string: "\(self.rockside.chain.etherscanAPIUrl)?module=account&action=\(action)&address=\(self.rockside.identity!.ethereumAddress)&startblock=0&endblock=99999999&sort=desc&apikey=\(etherscanApiKey)")!
        
        var request = URLRequest(url:url ,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            self.transactionCallRetrieved += 1
            
            guard let data = data else {
                print(String(describing: error))
                self.displayErrorHandler?()
                return
            }

            let decoder = JSONDecoder()
            if let response = try? decoder.decode(EtherscanTransactionResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.transactionsBuffer.append(contentsOf: response.result)
                    
                    self.transactionsBuffer = self.transactionsBuffer.filter{ $0.type != "Relay" }
                    
                    self.transactionsBuffer.sort {
                        $0.block > $1.block
                    }
                    
                    if (self.transactionCallRetrieved == 3){
                        self.transactions = self.transactionsBuffer
                        self.transactionViewController?.display(transactions: self.transactions)
                        self.transactionViewController?.refreshControl?.endRefreshing()
                        self.updateBalance()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.transactionViewController?.refreshControl?.endRefreshing()
                    self.displayErrorHandler?()
                }
            }
        }
        
        task.resume()
    }
    
    public func tokenBalanceArray() -> [TokenBalance] {
        var tokenBalances = Array<TokenBalance>(self.tokenBalances.values)
        
        tokenBalances.sort {
            if $0.symbol == "ETH" {
                return true
            }
            
            if $1.symbol == "ETH" {
                return false
            }
            
            return $1.symbol > $0.symbol
            
        }
        
        return tokenBalances
    }
    
    private func getEthBalance() {
        self.rockside.identity!.getBalance() { (result) in
            switch result {
            case .success(let balance):
                DispatchQueue.main.async {
                    self.hud.dismiss()
                    self.tokenBalances["ETH"]?.balance = balance
                    self.balanceViewController?.display(balances: self.tokenBalanceArray())
                    self.balanceViewController?.refreshControl?.endRefreshing()
                    self.balanceUpdatedHandler?()
                }
                
                break
            case .failure(let error):
                DispatchQueue.main.async {
                    self.balanceViewController?.refreshControl?.endRefreshing()
                    self.hud.dismiss()
                    print(error)
                }
                break
            }
        }
    }
    
    private func get(tokenBalance: TokenBalance) {
        
        self.rockside.identity!.getErc20Balance(ercAddress: tokenBalance.address!) { (result) in
            switch result {
            case .success(let balance):
                DispatchQueue.main.async {
                    self.hud.dismiss()
                    self.tokenBalances[tokenBalance.symbol]?.balance = balance
                    self.balanceViewController?.display(balances:self.tokenBalanceArray())
                }
                break
                
            case .failure(_):
                DispatchQueue.main.async {
                    self.hud.dismiss()
                    self.displayErrorHandler?()
                }
                break
            }
        }
        
    }
    
    private func updateBalance() {
        self.transactions.forEach {
            if $0.isERC {
                if (self.tokenBalances[$0.tokenSymbol!] == nil) {
                     self.tokenBalances[$0.tokenSymbol!] =  TokenBalance(name: $0.tokenName!, symbol: $0.tokenSymbol!, address: $0.contractAddress)
                }
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

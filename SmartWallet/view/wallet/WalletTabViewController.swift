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

import BigInt
import JGProgressHUD


typealias BalanceUpdatedHandler = () -> Void
typealias RefreshHandler = () -> Void

class WalletTabViewController: TabmanViewController {
    
    private var viewControllers: [UIViewController]?
    
    private var balanceViewController: BalanceViewContrller?
    private var transactionViewController: TransactionViewContrller?
    
    var balanceUpdatedHandler: BalanceUpdatedHandler?
    var tokenBalances:[String : TokenBalance] = ["ETH": TokenBalance(symbol: "ETH", decimals: 18, address: "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE")]
    
    var displayErrorHandler: DisplayErrorHandler?
    
    var transactions: [Transaction] = []
    var transactionsBuffer: [Transaction] = []
    var transactionCallRetrieved:Int = 0
    
    let etherscanService = EtherscanService()
    
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
        retrieveTransaction(action: .txlist)
        retrieveTransaction(action: .txlistinternal)
        retrieveTransaction(action: .tokentx)
    }
    
    private func retrieveTransaction(action: TxAction) {
        
        
        self.etherscanService.retrieveTransaction(action: action) { (result) in
            switch result {
            case .success(let response):
                
                self.transactionCallRetrieved += 1
                DispatchQueue.main.async {
                    if action == .txlistinternal {
                        self.transactionsBuffer = self.mergeValueOfInternalSendTX(txList: response.result)
                    } else {
                        self.transactionsBuffer.append(contentsOf: response.result)
                    }
                    
                    self.transactionsBuffer = self.transactionsBuffer.filter{ $0.type != .Relay && $0.type != .ContractCall}
                    
                    
                    self.transactionsBuffer.sort {
                        Transaction.sort(first: $0, second: $1)
                    }
                    
                    if (self.transactionCallRetrieved == 3){
                        self.transactions = self.transactionsBuffer
                        self.transactionViewController?.display(transactions: self.transactions)
                        self.transactionViewController?.refreshControl?.endRefreshing()
                        self.constructTokenBalanceFromTx()
                        Application.updateTokensPrices(tokens: Array<TokenBalance>(self.tokenBalances.values)) { (result) in
                            switch result{
                            case .success(_), .failure(_):
                                self.updateBalance()
                                break
                            }
                        }
                    }
                }
                return
                
            case .failure(_):
                self.transactionCallRetrieved += 1
                DispatchQueue.main.async {
                    self.transactionViewController?.refreshControl?.endRefreshing()
                    self.displayErrorHandler?()
                }
                return
            }
        }
    }
    
    private func mergeValueOfInternalSendTX(txList: [Transaction]) -> [Transaction]{
        var mergedResult = [Transaction]()
        
        for transaction in txList {
            //If an internal tx is arealdy present for a hash and new and present one are send tx, we make the sum of there value
            if  let index = mergedResult.firstIndex(where: { $0.hash == transaction.hash}), mergedResult[index].isSend(), transaction.isSend()  {
                var transactionToRaiseUp = mergedResult[index]
                transactionToRaiseUp.value = String(Int(transactionToRaiseUp.value)! + Int(transaction.value)!)
                mergedResult[index] = transactionToRaiseUp
                
            } else {
                mergedResult.append(transaction)
            }
        }
        
        return mergedResult
    }
    
    
    public func constructTokenBalanceFromTx() {
        self.transactions.forEach {
            if $0.isERC {
                if (self.tokenBalances[$0.tokenSymbol!] == nil) {
                    
                    self.tokenBalances[$0.tokenSymbol!] =  TokenBalance(symbol: $0.tokenSymbol!, decimals: Int($0.tokenDecimal!)!, address: $0.contractAddress)
                }
            }
        }
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
        
        Application.ethereumClient.eth_getBalance(address: Application.smartwallet!.address.value, block: .Latest) { (error, balance) in
            DispatchQueue.main.async {
                if error != nil || balance == nil  {
                    self.balanceViewController?.refreshControl?.endRefreshing()
                    self.hud.dismiss()
                    return
                }
                self.hud.dismiss()
                self.tokenBalances["ETH"]?.balance = balance
                self.tokenBalances["ETH"]?.decimals = 18
                self.balanceViewController?.display(balances: self.tokenBalanceArray())
                self.balanceViewController?.refreshControl?.endRefreshing()
                self.balanceUpdatedHandler?()
            }
        }
    }
    
    private func get(tokenBalance: TokenBalance) {
        Application.erc20.balanceOf(tokenContract: tokenBalance.ethereumAddress, address: Application.smartwallet!.address) { (error, balance) in
            DispatchQueue.main.async {
                if error != nil || balance == nil  {
                    self.hud.dismiss()
                    self.displayErrorHandler?()
                    return
                }
                
                self.hud.dismiss()
                self.tokenBalances[tokenBalance.symbol]?.balance = balance
                self.balanceViewController?.display(balances:self.tokenBalanceArray())
                self.balanceUpdatedHandler?()
            }
        }
    }
    
    private func updateBalance() {
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

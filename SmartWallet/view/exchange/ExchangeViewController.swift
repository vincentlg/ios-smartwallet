//
//  ExchangeViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 11/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import RocksideWalletSdk
import BigInt

struct GetTokenResponse:Codable {
    var tokens: [Token]
}

struct BuildTxResponse:Codable {
    var error: String?
    var from: String?
    var to: String?
    var value: String?
    var data: String?
    var gasPrice: String?
    var gas: String?
}


class ExchangeViewController: UIViewController {
    
    var tokens: [Token]?
    
    var sourceToken: Token?
    var destToken: Token?
    
    var amountWei: String?
    var destAmountWei: String?
    var priceRoute: NSDictionary?
    
    @IBOutlet weak var destLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var destAmountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getTokens()
    }
    
    @IBAction func amountValueChanged(_ sender: Any) {
        self.refreshView()
    }
    
    @IBAction func changeSourceAction(_ sender: Any) {
    }
    
    @IBAction func changeDestAction(_ sender: Any) {
    }
    
    @IBAction func buyAction(_ sender: Any) {
        
        self.getParaSwapTx()
    }
    
    private func refreshView(){
        self.sourceLabel.text = self.sourceToken?.symbol
        self.destLabel.text = self.destToken?.symbol
        
        self.getRate()
    }
    
    private func getTokens() {
        var request = URLRequest(url: URL(string: "https://paraswap.io/api/v1/tokens/1")!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            
            let decoder = JSONDecoder()
            let response = try! decoder.decode(GetTokenResponse.self, from: data)
            
            self.tokens = response.tokens
            
            self.tokens!.sort {
                
                if $0.symbol == "ETH" {
                    return true
                }
                
                if $1.symbol == "ETH" {
                    return false
                }
                
                if $0.symbol == "DAI" {
                    return true
                }
                
                if $1.symbol == "DAI" {
                    return false
                }
                
                return $0.symbol.lowercased() < $1.symbol.lowercased()
            }
            
            self.sourceToken = self.tokens![0]
            self.destToken = self.tokens![1]
            
            DispatchQueue.main.async {
                self.refreshView()
            }
        }
        
        task.resume()
    }
    
    private func getParaSwapTx(){
        
        let requestBody: [String: Any] = ["priceRoute": self.priceRoute!,
                                          "srcToken": self.sourceToken!.address,
                                          "destToken": self.destToken!.address,
                                          "srcAmount": self.amountWei!,
                                          "destAmount": self.destAmountWei!,
                                          "userAddress": self.rockside.identity!.ethereumAddress
        ]
        if let postData = (try? JSONSerialization.data(withJSONObject: requestBody, options: [])) {
            
            print(String(data: postData, encoding: .utf8)!)
            
            var request = URLRequest(url: URL(string: "https://paraswap.io/api/v1/transactions/1")!,timeoutInterval: Double.infinity)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.httpMethod = "POST"
            request.httpBody = postData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    print(String(describing: error))
                    return
                }
                
                let decoder = JSONDecoder()
                let response = try! decoder.decode(BuildTxResponse.self, from: data)
                
                if response.error != nil {
                    DispatchQueue.main.async {
                     let alertController = UIAlertController(title: "Error", message:
                        response.error, preferredStyle: .alert)
                       alertController.addAction(UIAlertAction(title: "Ok", style: .default))

                       self.present(alertController, animated: true, completion: nil)
                    }
                } else {
                    
                    print(response)
                    
                    let amount = BigInt(response.value!)
                    let weiAmount = amount?.magnitude.serialize()
                    
                    self.rockside.relayTransaction(to: response.to!,
                                              value: weiAmount!.hexValueNoLeadingZero,
                                              data: response.data!, gas: response.gas!) { (result) in
                                           switch result {
                                           case .success(let txhash):
                                               print(txhash)
                                               break
                                           case .failure(let error):
                                               print(error)
                                               break
                                           }
                                       }
                }
                
            }
            
            task.resume()
        }
    }
    
    private func getRate() {
        
        if amountTextField.text != ""{
            // let fullFormatter = EtherNumberFormatter()
            // let balanceString = fullFormatter.string(from: balance)
            let formatter = EtherNumberFormatter()
            let amountWeiBigInt = formatter.number(from: amountTextField.text!)!
            
            self.amountWei = amountWeiBigInt.description
            
            if (amountWei != "0") {
            
                var request = URLRequest(url: URL(string: "https://paraswap.io/api/v1/prices/1/\(sourceToken!.address)/\(destToken!.address)/"+self.amountWei!)!,timeoutInterval: Double.infinity)
                request.httpMethod = "GET"
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data else {
                        print(String(describing: error))
                        return
                    }
                    
                    guard let json = try? (JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary)  else{
                        return
                    }
                    
                    self.priceRoute = json["priceRoute"] as? NSDictionary
                    
                    //TODO: Ugly should define the struct instead of using dictionnary
                    self.destAmountWei = self.priceRoute!["amount"] as? String
                    
                    DispatchQueue.main.async {
                        let amountBigInt = BigInt(self.destAmountWei!)!
                        let amountString = formatter.string(from:amountBigInt)
                        self.destAmountLabel.text = amountString
                    }
                }
                
                task.resume()
            } else {
                self.destAmountLabel.text = "0"
            }
        } else {
            self.destAmountLabel.text = "0"
        }
    }
    
    
    func selectSourceToken(token: Token) -> Void {
        self.sourceToken = token
        self.refreshView()
        self.dismiss(animated: true)
    }
    
    func selectDestToken(token: Token) -> Void {
        self.destToken = token
        self.refreshView()
        self.dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "select-source-token-segue" {
            if let destinationVC = segue.destination as? TokensTableViewController {
                destinationVC.tokens = self.tokens
                destinationVC.selectionHandler = self.selectSourceToken
            }
        }
        
        if segue.identifier == "select-dest-token-segue" {
            if let destinationVC = segue.destination as? TokensTableViewController {
                destinationVC.tokens = self.tokens
                destinationVC.selectionHandler = self.selectDestToken
            }
        }
    }
    
    
}

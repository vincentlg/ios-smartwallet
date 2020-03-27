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
import MaterialComponents.MaterialTextFields

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
    
    @IBOutlet weak var maxAmountLabel: UILabel!
    @IBOutlet weak var destLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
       
    @IBOutlet weak var amountTextField: MDCTextField!
    var amountTextFieldController: MDCTextInputControllerUnderline?
    
    @IBOutlet weak var destAmountLabel: UILabel!
    
    var tokens: [Token]?
    var tokensBalance: [TokenBalance]?
    
    var sourceToken: TokenBalance?
    var destToken: Token?
    
    var amountWei: String?
    var destAmountWei: String?
    var priceRoute: NSDictionary?
    
    var watchTxHandler: WatchTxHandler?
    var displayErrorHandler: DisplayErrorHandler?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.amountTextFieldController = MDCTextInputControllerUnderline(textInput: amountTextField)
        self.amountTextField.becomeFirstResponder()
               self.getTokens()
               self.sourceToken = self.tokensBalance![0]
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
        self.maxAmountLabel.text = "Max: "+self.sourceToken!.formattedAmout
        self.destLabel.text = self.destToken?.symbol
        
        self.getRate()
    }
    
    public func selectSourceToken(token: TokenBalance) {
        self.sourceToken = token
        self.refreshView()
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
            
            
            self.destToken = self.tokens![1]
            
            DispatchQueue.main.async {
                self.refreshView()
            }
        }
        
        task.resume()
    }
    
    func getSourceTokenAddress() -> String {
        let sourceAddress: String
        if let address = self.sourceToken?.address {
            sourceAddress = address
        } else {
            sourceAddress = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
        }
        
        return sourceAddress
    }
        
    private func getParaSwapTx(){
        
        let requestBody: [String: Any] = ["priceRoute": self.priceRoute!,
                                          "srcToken": getSourceTokenAddress(),
                                          "destToken": self.destToken!.address,
                                          "srcAmount": self.amountWei!,
                                          "destAmount": self.destAmountWei!,
                                          "userAddress": self.rockside.identity!.ethereumAddress
        ]
        if let postData = (try? JSONSerialization.data(withJSONObject: requestBody, options: [])) {
            
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
                    
                    self.rockside.identity!.relayTransaction(to: response.to!,
                                                             value: weiAmount!.hexValueNoLeadingZero,
                                                             data: response.data!, gas: response.gas!) { (result) in
                                                                switch result {
                                                                case .success(let txHash):
                                                                    DispatchQueue.main.async {
                                                                        self.dismiss(animated: true, completion: {
                                                                            self.watchTxHandler?(txHash)
                                                                        })
                                                                    }
                                                                    break
                                                                    
                                                                case .failure(_):
                                                                    DispatchQueue.main.async {
                                                                        self.dismiss(animated: true, completion: {
                                                                            self.displayErrorHandler?()
                                                                        })
                                                                    }
                                                                    break
                                                                }
                    }
                }
                
            }
            
            task.resume()
        }
    }
    
    private func getRate() {
        let formatter = EtherNumberFormatter()
        if let amountText = amountTextField.text, let amountWeiBigInt = formatter.number(from:amountText) {
            
            self.amountWei = amountWeiBigInt.description
            
            if (amountWei != "0") {
                
                var request = URLRequest(url: URL(string: "https://paraswap.io/api/v1/prices/1/\(getSourceTokenAddress())/\(destToken!.address)/"+self.amountWei!)!,timeoutInterval: Double.infinity)
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
    
    func selectDestToken(token: Token) -> Void {
        self.destToken = token
        self.refreshView()
        self.dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "select-token-balance-segue" {
            if let destinationVC = segue.destination as? TokensSelectionViewController {
                destinationVC.tokens = self.tokensBalance
                destinationVC.selectionHandler = self.selectSourceToken
            }
        }
        
        if segue.identifier == "select-dest-token-segue" {
            if let destinationVC = segue.destination as? TokensTableViewController {
                print("LALLA")
                destinationVC.tokens = self.tokens
                destinationVC.selectionHandler = self.selectDestToken
            }
        }
    }
    
    
}

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
import JGProgressHUD

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
    
    var amountWei: BigInt?
    var destAmountWei: BigInt?
    var priceRoute: PriceRoute?
    
    var paraswapService = ParaswapService()
    
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
    
    public func selectSourceToken(token: TokenBalance) {
        self.sourceToken = token
        self.refreshView()
    }
    
    private func refreshView(){
        self.sourceLabel.text = self.sourceToken?.symbol
        self.maxAmountLabel.text = "Max: "+self.sourceToken!.formattedAmout
        self.destLabel.text = self.destToken?.symbol
        
        self.getRate()
    }
    
    private func getSourceTokenAddress() -> String {
        let sourceAddress: String
        if let address = self.sourceToken?.address {
            sourceAddress = address
        } else {
            sourceAddress = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
        }
        
        return sourceAddress
    }
    
    private func getTokens() {
        self.paraswapService.getTokens() { (result) in
            switch result {
            case .success(let response):
                self.tokens = response
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
                
                DispatchQueue.main.async {
                    self.destToken = self.tokens![1]
                    self.refreshView()
                }
                
                return
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.dispayErrorAlert(message: error.localizedDescription)
                }
                return
            }
        }
    }
    
    private func dispayErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func getParaSwapTx(){
        self.amountTextFieldController?.setErrorText(nil, errorAccessibilityValue:nil)
        
        if self.destAmountLabel.text == "0" {
            self.amountTextFieldController?.setErrorText("Amount invaid", errorAccessibilityValue: "Amount invaid")
            return
        }
        
        if self.amountWei! > sourceToken!.balance! {
            self.amountTextFieldController?.setErrorText("Insuffisant balance", errorAccessibilityValue: "Insuffisant balance")
            return
        }
        
        
        let body = GetTxRequest(priceRoute: self.priceRoute!,
                                srcToken: getSourceTokenAddress(),
                                destToken: self.destToken!.address,
                                srcAmount: self.amountWei!.description,
                                destAmount: self.destAmountWei!.description,
                                userAddress: self.rockside.identity!.ethereumAddress)
        
        let hud = JGProgressHUD(style: .dark)
        hud.show(in: self.view)
        
        
        self.paraswapService.getParaswapTx(body: body) { (result) in
            switch result {
            case .success(let response):
                let amount = BigInt(response.value!)
                let weiAmount = amount?.magnitude.serialize()
                
                DispatchQueue.main.async {
                    self.rockside.identity!.relayTransaction(to: response.to!,
                                                             value: weiAmount!.hexValueNoLeadingZero,
                                                             data: response.data!, gas: response.gas!) { (result) in
                                                                switch result {
                                                                case .success(let txHash):
                                                                    DispatchQueue.main.async {
                                                                        hud.dismiss()
                                                                        self.dismiss(animated: true, completion: {
                                                                            self.watchTxHandler?(txHash)
                                                                        })
                                                                    }
                                                                    break
                                                                    
                                                                case .failure(let error):
                                                                    print(error)
                                                                    DispatchQueue.main.async {
                                                                        hud.dismiss()
                                                                        self.dismiss(animated: true, completion: {
                                                                            self.displayErrorHandler?()
                                                                        })
                                                                    }
                                                                    break
                                                                }
                    }
                }
                
                return
                
            case .failure(let error):
                DispatchQueue.main.async {
                    hud.dismiss()
                    self.dispayErrorAlert(message: error.localizedDescription)
                }
                return
            }
            
        }
    }
    
    private func getRate() {
        let formatter = EtherNumberFormatter()
        if let amountText = amountTextField.text, let amountWeiBigInt = formatter.number(from:amountText) {
            self.amountWei = amountWeiBigInt
            if (amountWei?.description != "0") {
                self.paraswapService.getRate(sourceTokenAddress: getSourceTokenAddress(), destTokenAddress: destToken!.address, amount: amountWei!.description) { (result) in
                    switch result {
                    case .success(let response):
                        self.priceRoute = response
                        
                        let destAmountBigInt =  BigInt(response.amount)!
                        let desAmountWithMargin = destAmountBigInt * BigInt(90) / BigInt(100)
                        self.destAmountWei = desAmountWithMargin
                        
                        DispatchQueue.main.async {
                            let amountString = formatter.string(from:desAmountWithMargin)
                            let shortAmountString = String(format: "%.3f", (amountString as NSString).floatValue)
                            self.destAmountLabel.text = shortAmountString
                        }
                        
                        return
                        
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.dispayErrorAlert(message: error.localizedDescription)
                        }
                        return
                    }
                }
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
                destinationVC.tokens = self.tokens
                destinationVC.selectionHandler = self.selectDestToken
            }
        }
    }
}

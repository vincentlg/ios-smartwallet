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
    
    @IBAction func showParaswapInfo(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://paraswap.io")!, options: [:], completionHandler: nil)
    }
    var tokens: [Token]?
    var tokensBalance: [TokenBalance]?
    
    var sourceToken: TokenBalance?
    var destToken: Token?
    
    var amountWei: BigInt?
    var destAmountWei: BigInt?
    var priceRoute: PriceRoute?
    
    var paraswapService = ParaswapService()
    var moonkeyService = MoonkeyService()
    
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
        self.amountTextFieldController?.setErrorText(nil, errorAccessibilityValue:nil)
        
        if self.destAmountLabel.text == "0" {
            self.amountTextFieldController?.setErrorText("Amount invaid", errorAccessibilityValue: "Amount invaid")
            return
        }
        
        if self.amountWei! > sourceToken!.balance! {
            self.amountTextFieldController?.setErrorText("Insuffisant balance", errorAccessibilityValue: "Insuffisant balance")
            return
        }
        
        if self.tokensBalance![0].balance! < BigInt(1000000000000000)  {
            self.amountTextFieldController?.setErrorText("Need more ETH for gas", errorAccessibilityValue: "Need more ETH for gas")
            return
        }
        
        
        self.view.endEditing(true)
        if (sourceToken?.symbol == "ETH") {
            self.executeParaswapExchange()
        } else {
            self.erc20ApproveAndExecuteParaswap()
        }
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
    
    
    
    private func erc20ApproveAndExecuteParaswap(){
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Allowing Paraswap"
        hud.show(in: self.view)
        
        self.paraswapService.getParaswapSenderAddress() { (result) in
            switch result {
            case .success(let result):
                DispatchQueue.main.async {
                    /*self.rockside.identity!.erc20Approve(ercAddress: self.getSourceTokenAddress(), spender: result, value: self.amountWei!.description) { (result) in
                     switch result {
                     case .success(let txResponse):
                     DispatchQueue.main.async {
                     //TODO
                     /*_ = self.rockside.waitTxToBeMined(trackingID: txResponse.tracking_id) { (result) in
                     switch result {
                     case .success(_):
                     NSLog("Success")
                     DispatchQueue.main.async {
                     hud.dismiss()
                     self.executeParaswapExchange()
                     }
                     break
                     
                     case .failure(let error):
                     print(error)
                     DispatchQueue.main.async {
                     hud.dismiss()
                     self.dispayErrorAlert(message: error.localizedDescription)
                     }
                     break
                     }
                     }*/
                     }
                     
                     break
                     
                     case .failure(let error):
                     print(error)
                     DispatchQueue.main.async {
                     hud.dismiss()
                     self.dispayErrorAlert(message: error.localizedDescription)
                     }
                     break
                     }
                     
                     }*/
                }
                break
            case .failure(let error):
                print(error)
                break
            }
        }
        
    }
    
    
    private func executeParaswapExchange(){
        
        let body = GetTxRequest(priceRoute: self.priceRoute!,
                                srcToken: getSourceTokenAddress(),
                                destToken: self.destToken!.address,
                                srcAmount: self.amountWei!.description,
                                destAmount: self.destAmountWei!.description,
                                userAddress: Identity.current!.ethereumAddress)
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Executing transfer"
        hud.show(in: self.view)
        
        self.paraswapService.getParaswapTx(body: body) { (result) in
            switch result {
            case .success(let response):
                
               
                let messageData = Identity.current!.encodeExecute(to:  self.paraswapService.paraswapContract, value: BigUInt(response.value!)!, data: Data(hexString: response.data!)!)

                DispatchQueue.main.async {
                    print(response.gas!)
                    //TODO ADD value to gas for Rockside
                    self.moonkeyService.relayTransaction(identity: Identity.current!, messageData: messageData, gas: "460363") { (result) in
                        switch result {
                        case .success(let txResponse):
                            DispatchQueue.main.async {
                                hud.dismiss()
                                self.dismiss(animated: true, completion: {
                                    self.watchTxHandler?(txResponse)
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
                    NSLog("PARASWAP ERROR")
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
                        
                        // We take a marge of 5% to avoid market change
                        let destAmountBigInt =  BigInt(response.amount)!
                        let desAmountWithMargin = destAmountBigInt * BigInt(95) / BigInt(100)
                        self.destAmountWei = desAmountWithMargin
                        
                        //Update priceRoute object with marged amount
                        self.priceRoute?.amount = self.destAmountWei!.description
                        
                        DispatchQueue.main.async {
                            let amountString = formatter.string(from:desAmountWithMargin)
                            let shortAmountString = String(format: "%.3f", (amountString.replacingOccurrences(of: ",", with: ".") as NSString).floatValue)
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

//
//  ExchangeViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 11/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import BigInt
import MaterialComponents.MaterialTextFields
import JGProgressHUD
import web3

class ExchangeViewController: UIViewController {
    
    @IBOutlet weak var maxAmountLabel: UILabel!
    @IBOutlet weak var destLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var slippageLabel: UILabel!
    
    @IBOutlet weak var buyButton: WalletButton!
    @IBOutlet weak var amountTextField: MDCTextField!
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var amountTextFieldController: MDCTextInputControllerUnderline?
    
    @IBOutlet weak var destAmountLabel: UILabel!
    
    @IBAction func showParaswapInfo(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://paraswap.io")!, options: [:], completionHandler: nil)
    }
    
    
    let slippage = 3
    
    var tokens: [Token]?
    var tokensBalance: [TokenBalance]?
    
    var sourceToken: TokenBalance?
    var destToken: Token?
    
    var amountWei: BigUInt?
    var destAmountWei: BigUInt?
    var priceRoute: PriceRoute?
    
    var allowanceAmount: BigUInt?
    
    var paraswapService = ParaswapService()
    var moonkeyService = MoonkeyService()
    
    var watchTxHandler: WatchTxHandler?
    var displayErrorHandler: DisplayErrorHandler?
    
    var paraswapAllowanceAddress: web3.EthereumAddress?
    
    var paraswapTxResponse: GetTxResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hud = JGProgressHUD(style: .dark)
        hud.show(in: self.view)
        Application.updateEthPrice() { (result) in
            switch result {
            case .failure(_), .success(_):
                self.paraswapService.getParaswapSenderAddress() { (result) in
                    switch result {
                    case .success(let address):
                        DispatchQueue.main.async {
                            hud.dismiss()
                            self.paraswapAllowanceAddress = address
                        }
                        return
                    case .failure(_):
                        DispatchQueue.main.async {
                            self.dispayErrorAlert(message: "Error when loading exchange, please try again later") { (_) in
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                        return
                    }
                }
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.amountTextFieldController = MDCTextInputControllerUnderline(textInput: amountTextField)
        self.amountTextField.clearButtonMode = .never
        self.amountTextField.becomeFirstResponder()
        self.getTokens()
        self.sourceToken = self.tokensBalance![0]
        
        self.loader.isHidden = true
        self.loader.startAnimating()
       
    }
    
    @IBAction func amountValueChanged(_ sender: Any) {
        self.refreshView()
    }
    
    
    @IBAction func buyAction(_ sender: Any) {
        
        if (self.isApproveRequired()){
            self.performSegue(withIdentifier: "approve_segue", sender: self)
            return
        }
        
        
        self.amountTextFieldController?.setErrorText(nil, errorAccessibilityValue:nil)
        
        if self.destAmountLabel.text == "0" {
            self.amountTextFieldController?.setErrorText("Amount invaid", errorAccessibilityValue: "Amount invaid")
            return
        }
        
        if self.amountWei! > sourceToken!.balance! {
            self.amountTextFieldController?.setErrorText("Insuffisant balance", errorAccessibilityValue: "Insuffisant balance")
            return
        }
        
        if self.sourceToken?.symbol == destToken?.symbol {
            self.amountTextFieldController?.setErrorText("Change dest token", errorAccessibilityValue: "Change dest token")
            return
        }
        
        if self.destAmountLabel.text == "" {
            self.amountTextFieldController?.setErrorText("Receive value missing", errorAccessibilityValue: "Receive token missing")
            return
        }
        
        self.view.endEditing(true)
        self.getParasawapTx()
    }
    
    public func selectSourceToken(token: TokenBalance) {
        self.sourceToken = token
        self.refreshView()
    }
    
    private func refreshView(){
        self.amountTextFieldController?.setErrorText(nil, errorAccessibilityValue: nil)
        self.paraswapTxResponse = nil
        self.buyButton.setTitle("Validate", for: .normal)
        self.sourceLabel.text = self.sourceToken?.symbol
        self.maxAmountLabel.text = "Max: "+self.sourceToken!.formattedBalance
        self.destLabel.text = self.destToken?.symbol
        self.cleanDestAmount()
        self.getRate()
        
        if self.sourceToken!.symbol != "ETH" {
            Application.erc20.allowance(tokenContract: self.sourceToken!.ethereumAddress,
                                        address: Application.smartwallet!.address,
                                        spender: self.paraswapAllowanceAddress!)  { (error, allowance) in
                                            DispatchQueue.main.async {
                                                if error != nil || allowance == nil  {
                                                    
                                                    self.dispayErrorAlert(message: "Error when getting allowance, please try again later") { (_) in
                                                        self.dismiss(animated: true, completion: nil)
                                                        
                                                    }
                                                }
                                                self.allowanceAmount = allowance!
                                                if self.isApproveRequired() {
                                                    self.buyButton.setTitle("Approve", for: .normal)
                                                }
                                            }
            }
            
            
        }
    }
    
    private func isApproveRequired() -> Bool {
        if let requiredAmount = self.amountWei, let allowance = self.allowanceAmount, self.sourceToken!.symbol != "ETH" && requiredAmount > allowance {
            return true
        }
        return false
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
    
    private func dispayErrorAlert(message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: "Error", message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler ))
        
        self.present(alertController, animated: true)
    }
    
    
    private func getParaswapTx(completion: @escaping (Result<GetTxResponse, Error>) -> Void) -> Void {
        let body = GetTxRequest(priceRoute: self.priceRoute!,
                                srcToken: self.sourceToken!.address,
                                destToken: self.destToken!.address,
                                srcAmount: self.amountWei!.description,
                                destAmount: self.destAmountWei!.description,
                                userAddress: Application.smartwallet!.address.value)
        
        
        self.paraswapService.getParaswapTx(body: body, completion: completion)
    }
    
    private func getParasawapTx(){
        
        let hud = JGProgressHUD(style: .dark)
        hud.show(in: self.view)
        
        self.getParaswapTx() { (result) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    hud.dismiss()
                    self.paraswapTxResponse = response
                    self.performSegue(withIdentifier: "validate_tx_segue", sender: self)
                }
                
                return
                
            case .failure(let error):
                DispatchQueue.main.async {
                    hud.dismiss()
                    var message = error.localizedDescription
                    
                    if message.contains("This transaction has some errors and may fail."){
                          message = "Do you have enough ETH to pay for the gas. When network is congestionned gas fees for a swap can be higher than 0.1 ETH. \n\n"+message
                    }
          
                   
                    self.dispayErrorAlert(message:message)
                }
                return
            }
            
        }
    }
    
    private func getRate() {
        
        if let amountText = amountTextField.text, let amountWeiBigInt = sourceToken?.token?.amountFrom(value: amountText){
            self.amountWei = BigUInt(amountWeiBigInt)
            if (amountWei?.description != "0") {
                 self.loader.isHidden = false
                 self.paraswapService.getRate(sourceTokenAddress: self.sourceToken!.address, destTokenAddress: destToken!.address, amount: amountWei!.description) { (result) in
                    switch result {
                    case .success(let response):
                        self.priceRoute = response
                        
                        let destAmountBigInt =  BigUInt(response.amount)!
                        
                        let formattedMaxAmount = self.destToken!.shortAmount(amount: BigInt(destAmountBigInt))
                        
                        
                        // Slippafe: We take a marge of x% to avoid market change :
                        let desAmountWithMargin = destAmountBigInt * BigUInt(100 - self.slippage) / BigUInt(100)
                        self.destAmountWei = desAmountWithMargin
                        
                        //Update priceRoute object with marged amount
                        self.priceRoute?.amount = self.destAmountWei!.description
                        
                        DispatchQueue.main.async {
                            self.loader.isHidden = true
                            self.destAmountLabel.text = self.destToken!.shortAmount(amount: BigInt(desAmountWithMargin))
                            self.slippageLabel.text = "Max: \(formattedMaxAmount) (\(self.slippage)% slippage)"
                        }
                        return
                        
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.loader.isHidden = true
                            self.dispayErrorAlert(message: error.localizedDescription)
                        }
                        return
                    }
                }
            } else {
                self.cleanDestAmount()
            }
        } else {
            self.cleanDestAmount()
        }
    }
    
    func cleanDestAmount() {        
        self.destAmountWei = BigUInt(0)
        self.slippageLabel.text = ""
        self.destAmountLabel.text = ""
    }
    
    func selectDestToken(token: Token) -> Void {
        self.destToken = token
        self.refreshView()
        self.dismiss(animated: true)
    }
    
    private func tradeSuccessHandler(relayResponse: RelayResponse) -> Void {
        self.dismiss(animated: true) {
            self.watchTxHandler?(relayResponse)
        }
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
        
        if segue.identifier == "approve_segue" {
            if let destinationVC = segue.destination as? ApproveViewController {
                destinationVC.sourceToken = self.sourceToken
                destinationVC.paraswapAllowanceAddress = self.paraswapAllowanceAddress
                destinationVC.approveSuccessHandler = self.refreshView
                destinationVC.baseAmount  = self.amountWei
            }
        }
        
        if segue.identifier == "validate_tx_segue" {
            if let destinationVC = segue.destination as? ValidateTradeViewController {
                destinationVC.sourceToken = self.sourceToken
                destinationVC.destToken = self.destToken
                destinationVC.sourceAmount = self.amountTextField.text
                destinationVC.destAmount = self.destAmountLabel.text
                destinationVC.maxDestAmount = self.slippageLabel.text
                destinationVC.paraswapTx = self.paraswapTxResponse
                destinationVC.watchTxHandler = self.tradeSuccessHandler
            }
        }
    }
    
}

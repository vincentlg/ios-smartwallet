//
//  ApproveViewController.swift
//  SmartWallet
//
//  Created by Fred on 27/08/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextFields
import web3
import JGProgressHUD
import BigInt

class ApproveViewController: UIViewController {
    
    
    @IBOutlet weak var approveAmount: MDCTextField!
    
    @IBOutlet weak var GasFeesLabel: UILabel!
    var sourceToken: TokenBalance?
    var paraswapAllowanceAddress: web3.EthereumAddress?
    var approveSuccessHandler: (() -> Void)?
    var baseAmount: BigUInt?
    
    var approveAmountTextFieldController: MDCTextInputControllerUnderline?
    let moonkeyService = MoonkeyService()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.approveAmountTextFieldController = MDCTextInputControllerUnderline(textInput: approveAmount)
        self.approveAmount.becomeFirstResponder()
        self.approveAmount.text = self.sourceToken?.formatAmount(amount: BigInt(self.baseAmount!))
        
        Application.calculateGasFees(safeGas: BigUInt(15000)) { (result) in
            switch result {
            case .success(let fees):
                DispatchQueue.main.async {
                    self.GasFeesLabel.text = fees
                }
                return
            case .failure(_):
                self.GasFeesLabel.text = "error"
                return
            }
            
        }
    }
    
    @IBAction func approveTouched(_ sender: Any) {
        if let amountText = approveAmount.text, let amountWeiBigInt = sourceToken?.amountFrom(value: amountText){
            
            let amountWei = BigUInt(amountWeiBigInt)
            let hud = JGProgressHUD(style: .dark)
            hud.textLabel.text = "Allowing Paraswap\nto use "+self.approveAmount.text!+" "+self.sourceToken!.symbol
            hud.show(in: self.view)
            
            let erc20ApproveData = ERC20Encoder.encodeApprove(spender: EthereumAddress(string:self.paraswapAllowanceAddress!.value)!, tokens:  amountWei)
            
            Application.relay(to: web3.EthereumAddress(self.sourceToken!.address), value: BigUInt(0), data: erc20ApproveData, safeTxGas: BigUInt(15000)) { (result) in
                switch result {
                case .success(let txResponse):
                    DispatchQueue.main.async {
                        _ = self.moonkeyService.waitTxToBeMined(trackingID: txResponse.tracking_id) { (result) in
                            
                            switch result {
                            case .success(_):
                                DispatchQueue.main.async {
                                    hud.dismiss()
                                    self.dismiss(animated: true) {
                                        self.approveSuccessHandler?()
                                    }
                                }
                                break
                                
                            case .failure(let error):
                                DispatchQueue.main.async {
                                    hud.dismiss()
                                    self.dispayErrorAlert(message: error.localizedDescription)
                                }
                                break
                            }
                        }
                    }
                    
                    break
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        hud.dismiss()
                        self.dispayErrorAlert(message: error.localizedDescription)
                    }
                    break
                }
                
            }
        } else {
            approveAmountTextFieldController?.setErrorText("Invalid amount", errorAccessibilityValue: "Invalid amount")
        }
    }
    private func dispayErrorAlert(message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: "Error", message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler ))
        
        self.present(alertController, animated: true)
    }
    
    
}

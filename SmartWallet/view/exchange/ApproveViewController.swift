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
    let backendService = BackendService()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.approveAmountTextFieldController = MDCTextInputControllerUnderline(textInput: approveAmount)
        self.approveAmount.becomeFirstResponder()
        self.approveAmount.text = self.sourceToken?.shortAmount(amount: BigInt(self.baseAmount!))
        
        Application.updateGasPrice() { (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    let gas = BigUInt(15000)
                    self.GasFeesLabel.text = Application.calculateGasFees(safeGas: gas)
                }
                return
            case .failure(_):
                DispatchQueue.main.async {
                    self.GasFeesLabel.text = "error"
                }
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
            
            let to = web3.EthereumAddress(self.sourceToken!.address)
            let function = ERC20Functions.approve(contract: to, spender: self.paraswapAllowanceAddress!, value: amountWei)
            let transaction = try! function.transaction()
            
            Application.relay(to: to, value: BigUInt(0), data: transaction.data!, safeTxGas: BigUInt(30000)) { (result) in
                switch result {
                case .success(let txResponse):
                    DispatchQueue.main.async {
                        _ = Application.backendService.waitTxToBeMined(trackingID: txResponse.tracking_id) { (result) in
                            
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

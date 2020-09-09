//
//  WhitelistAddressViewController.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 08/04/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialSnackbar
import JGProgressHUD
import web3
import BigInt

typealias SuccessHandler = () -> Void

class AddOwnerViewController:UIViewController {
    
    @IBOutlet weak var gasFeesLabel: UILabel!
    @IBOutlet weak var addressTextField: MDCTextField!
    
    var addressTextFieldController: MDCTextInputControllerUnderline?
    
    
    var successHandler: SuccessHandler?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addressTextFieldController = MDCTextInputControllerUnderline(textInput: addressTextField)
        self.addressTextField.becomeFirstResponder()
        
        let hud = JGProgressHUD(style: .dark)
        hud.show(in: self.view)
        Application.updateEthPrice() { (result) in
            switch result {
            case .failure(_), .success(_):
                DispatchQueue.main.async {
                    Application.updateGasPrice() { (result) in
                        switch result {
                        case .success(_):
                            DispatchQueue.main.async {
                                hud.dismiss()
                                let gas = BigUInt(50000)
                                self.gasFeesLabel.text = Application.calculateGasFees(safeGas: gas)
                            }
                            return
                        case .failure(_):
                            DispatchQueue.main.async {
                                hud.dismiss()
                                self.gasFeesLabel.text = "error"
                            }
                            return
                        }
                        
                    }
                    
                }
                break
            }
        }
    }
    
    @IBAction func addAction(_ sender: Any) {
        self.addressTextFieldController?.setErrorText(nil, errorAccessibilityValue: nil)
        
        if  !EthereumAddress.isValid(string: addressTextField.text!) {
            self.addressTextFieldController?.setErrorText("Invalid address", errorAccessibilityValue: "Invalid addresss")
            return
        }
        
        
        let hud = JGProgressHUD(style: .extraLight)
        hud.textLabel.text = "Your address is being added.\nPlease wait (around 1 min)"
        hud.show(in: self.view)
        
        
        let data = Application.smartwallet!.encodeAddOwnerWithThreshold(owner:  web3.EthereumAddress(self.addressTextField.text!),
                                                                        threshold: BigUInt(1))
        
        Application.relay(to: Application.smartwallet!.address, value: BigUInt(0), data: Data(hexString: data)!, safeTxGas: BigUInt(50000)) { (result) in
            switch result {
                
            case .success(let txResponse):
                DispatchQueue.main.async {
                    _ = Application.backendService.waitTxToBeMined(trackingID: txResponse.tracking_id) { (result) in
                        switch result {
                        case .success(_):
                            DispatchQueue.main.async {
                                hud.dismiss()
                                
                                self.dismiss(animated: true) {
                                    self.successHandler?()
                                }
                            }
                            break
                            
                        case .failure(_):
                            DispatchQueue.main.async {
                                hud.dismiss()
                                self.displayErrorOccured()
                            }
                            break
                        }
                    }
                    
                }
                break
                
            case .failure(_):
                DispatchQueue.main.async {
                    hud.dismiss()
                    self.displayErrorOccured()
                }
                break
            }
        }
    }
    
    
    public func displayErrorOccured() {
        let snackBarMessage = MDCSnackbarMessage()
        snackBarMessage.text = "An error occured. Please try again."
        MDCSnackbarManager.default.show(snackBarMessage)
    }
    
    func qrCodeFound(qrcode: String) {
        let address = qrcode.replacingOccurrences(of: "ethereum:", with: "")
        self.addressTextField.text = address
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_scanner_segue" {
            if let destinationVC = segue.destination as? ScannerViewController {
                destinationVC.qrCodeHandler = self.qrCodeFound
            }
        }
    }
    
}

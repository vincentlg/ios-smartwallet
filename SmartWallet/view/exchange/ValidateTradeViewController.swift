//
//  ValidateTradeViewController.swift
//  SmartWallet
//
//  Created by Fred on 27/08/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import UIKit
import web3
import BigInt
import JGProgressHUD

class ValidateTradeViewController: UIViewController {
    
    @IBOutlet weak var sourceTokenLabel: UILabel!
    @IBOutlet weak var sourceAmountLabel: UILabel!
    @IBOutlet weak var desTokenLabel: UILabel!
    @IBOutlet weak var destAmountLabel: UILabel!
    @IBOutlet weak var slipageLabel: UILabel!
    @IBOutlet weak var gasFeesLabel: UILabel!
    
    var paraswapTx:GetTxResponse?
    let paraswapService: ParaswapService = ParaswapService()
    var watchTxHandler: WatchTxHandler?
    var sourceToken: TokenBalance?
    var destToken: Token?
    
    var sourceAmount: String?
    var destAmount: String?
    var maxDestAmount: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.sourceTokenLabel.text = self.sourceToken?.symbol
        self.sourceAmountLabel.text = self.sourceAmount
        self.destAmountLabel.text = self.destAmount
        self.desTokenLabel.text = self.destToken?.symbol
        self.slipageLabel.text = self.maxDestAmount
        
        Application.updateGasPrice() { (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    let gas = BigUInt(self.paraswapTx!.gas!)!
                    self.gasFeesLabel.text = Application.calculateGasFees(safeGas: gas)
                }
                return
            case .failure(_):
                self.gasFeesLabel.text = "error"
                return
            }
        }
        
    }
    
    @IBAction func buyAction(_ sender: Any) {
        self.executeTrade()
    }
    
    @IBAction func paraswapAction(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://paraswap.io")!, options: [:], completionHandler: nil)
    }
    
    private func executeTrade() {
        guard let tx = self.paraswapTx else {
            return
        }
        
        let hud = JGProgressHUD(style: .dark)
        hud.show(in: self.view)
        
        Application.relay(to: web3.EthereumAddress(self.paraswapService.paraswapContract), value: BigUInt(tx.value!)!, data: Data(hexString: tx.data!)!, safeTxGas: BigUInt(tx.gas!)!) { (result) in
            switch result {
            case .success(let txResponse):
                DispatchQueue.main.async {
                    hud.dismiss()
                    self.dismiss(animated: true, completion: {
                        self.watchTxHandler?(txResponse)
                    })
                }
                break
                
            case .failure(_):
                DispatchQueue.main.async {
                    hud.dismiss()
                    self.dismiss(animated: true, completion: {
                        self.dispayErrorAlert(message: "An error occured, please try again")
                    })
                }
                break
            }
        }
    }
    
    private func dispayErrorAlert(message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: "Error", message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler ))
        
        self.present(alertController, animated: true)
    }
}

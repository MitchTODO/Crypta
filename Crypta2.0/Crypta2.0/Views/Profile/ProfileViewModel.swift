//
//  ProfileViewModel.swift
//  Crypta
//
//  Created by Mitch on 7/14/22.
//

import Foundation
import web3swift
import SwiftUI
import CoreImage.CIFilterBuiltins


struct TxParams {
    var from:String = ""
    var to:String = ""
    var value:String = ""
}


class ProfileViewModel:ObservableObject {

    @Published var lastTx:WriteTransaction?
    @Published var txParams:TxParams = TxParams()
    @Published var error:CryptaError?
    @Published var showProgress = false
    
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    var sendDisabled:Bool {
        txParams.to.isEmpty || txParams.value.isEmpty || showProgress
    }
    
    
    func generateQRCode(from string: String) -> UIImage {
            let data = Data(string.utf8)
            filter.setValue(data, forKey: "inputMessage")
            if let qrCodeImage = filter.outputImage {
                if let qrCodeCGImage = context.createCGImage(qrCodeImage, from: qrCodeImage.extent) {
                    return UIImage(cgImage: qrCodeCGImage)
                }
            }
            return UIImage(systemName: "xmark") ?? UIImage()
        }
    
    func sendToken(to:String,value:String,password:String,token:ERC20Token,completion:@escaping(TransactionSendingResult) -> Void) {
        
        showProgress = true
        
        Web3Services.shared.sendTokens(token: token, value: value, to: to, password: password) {
            result in
            DispatchQueue.main.async { [unowned self] in
                showProgress = false
                switch(result){
                case .success(let tx):
                    completion(tx)
                case .failure(let txError):
                    self.error = CryptaError(description: txError.errorDescription)
                    
                }
            }
        }
    }    
}

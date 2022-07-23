//
//  BalanceView.swift
//  Crypta
//
//  Created by Mitch on 7/14/22.
//

import SwiftUI
import BigInt
import web3swift

// MARK: BalanceView

class Reload:ObservableObject{
    @Published var shouldReload = false
}

struct BalanceView: View {
    
    let token:ERC20Token
    @State var balance:String = ""
    @State var error:Web3Services.Web3ServiceError?
    @EnvironmentObject var reload:Reload
    @State private var showProgress = false
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5){
            Text(token.name)
            HStack{
                Text(balance)
                Text(token.symbol)
            }
        
            
            if showProgress{
                ProgressView()
                           .progressViewStyle(CircularProgressViewStyle(tint: Color("Prime")))
                           .scaleEffect(1.5, anchor: .center)
                           .zIndex(1)
                           
            }

        }.task(id:reload.shouldReload ) {
            
            showProgress = true
            let walletAddress = Web3Services.shared.getWallet()
            let params = [walletAddress.address] as [AnyObject]
            Web3Services.shared.readContractMethod(contractAddress: token.address, contractABI: Web3.Utils.erc20ABI, method: "balanceOf", parameters: params) { result in
                DispatchQueue.main.async { [self] in
                    reload.shouldReload = false
                    showProgress = false
                    switch(result){
                    case .success(let result):
                        let balanceBigUInt = result["0"] as! BigUInt
                        let balanceString = Web3.Utils.formatToEthereumUnits(balanceBigUInt, toUnits: .eth, decimals: 3)!
                        balance = balanceString
                    case .failure(let error):
                        self.error = Web3Services.Web3ServiceError(title: "Failed to get balance.", description: error.errorDescription)
                    }
                }
            }
        }
        
        .alert(item:$error) { error in
            Alert(title: Text(error.title), message: Text(error.description), dismissButton: .cancel() {})
        }
    }
}

struct BalanceView_Previews: PreviewProvider {
    static var previews: some View {
        BalanceView(token:CELO)
    }
}

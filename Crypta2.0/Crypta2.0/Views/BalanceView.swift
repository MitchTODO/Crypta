//
//  BalanceView.swift
//  Crypta
//
//  Created by Mitch on 7/14/22.
//

import SwiftUI
import BigInt

// MARK: BalanceView

class Reload:ObservableObject{
    @Published var shouldReload = false
}

struct BalanceView: View {
    
    let token:ERC20Token
    @State var balance:String = ""
    @State var error:CryptaError?
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
            Web3Services.shared.getTokenBalance(token: token) { result in
                showProgress = false
                DispatchQueue.main.async { [self] in
                    reload.shouldReload = false
                }
                switch(result){
                    
                case .success(let value):
                    balance = value
                case .failure(let error):
                    self.error = CryptaError(description: error.localizedDescription)
                }
            }
        }
        
        .alert(item:$error) { error in
                Alert(title: Text("Failed to create new group."), message: Text(error.description), dismissButton: .cancel() {
                    
                })
        }
        
    }
}

struct BalanceView_Previews: PreviewProvider {
    static var previews: some View {
        BalanceView(token:CELO)
    }
}

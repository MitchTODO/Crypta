//
//  ProfileView.swift
//  Crypta
//
//  Created by Mitch on 7/14/22.
//

import SwiftUI
import CodeScanner
import web3swift


struct ProfileView: View {
    
    private var wallet:Wallet = Web3Services.shared.getWallet()

    @StateObject private var profileVM = ProfileViewModel()
    @StateObject private var reload = Reload()
    @EnvironmentObject var contentVM:ContentViewModel
    
    
    @State private var isShowingScanner = false
    
    @State private var to:String = ""
    @State private var value:String = ""
    @State private var password = ""
    @State private var senderToken = CELO
    
    var body: some View {
        ZStack{
            ScrollView{
            VStack(alignment: .center){
                Text("Balances").font(.title3)
                HStack(alignment: .top, spacing: 60){
                    VStack(alignment: .leading, spacing: 20){
                        BalanceView(token: CELO).environmentObject(reload)
                        BalanceView(token: cUSD).environmentObject(reload)
                    }
                    VStack(alignment: .trailing, spacing: 20){
                        BalanceView(token: cEUR).environmentObject(reload)
                        BalanceView(token: cREAL).environmentObject(reload)
                    }
                }
                
                Divider()
                Text("Send").font(.title3)
                
                Spacer()
                VStack(alignment:.leading){
                    
                    HStack {
                        TextField("To",text: $to)
                            .font(.subheadline)
                            .truncationMode(.middle)
                            .padding(EdgeInsets(top: 8, leading: 16,
                                                bottom: 8, trailing: 16))
                        
                            .shadow(color: Color.gray.opacity(0.4),
                                    radius: 3, x: 1, y: 2)
                        
                        Button {
                            isShowingScanner = true
                        } label: {
                            Image(uiImage: UIImage(named: "QRIcon")!)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .disabled(isShowingScanner)
                        }
                    }
                    TextField("CELO Amount",text: $value)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .padding(EdgeInsets(top: 8, leading: 16,
                                            bottom: 8, trailing: 16))
                    
                        .shadow(color: Color.gray.opacity(0.4),
                                radius: 3, x: 1, y: 2)
                        .submitLabel(.done)
                    
                    TextField("Wallet Password", text: $password)
                        .padding(EdgeInsets(top: 8, leading: 16,
                                            bottom: 8, trailing: 16))
                    
                        .shadow(color: Color.gray.opacity(0.4),
                                radius: 3, x: 1, y: 2)
                    
                    Button {
                        contentVM.sendingWriteTx = true // disable list and navibar add
                        contentVM.popOverGroup = false // dimiss popOver
                        
                        profileVM.sendToken(to: to, value: value, password: password, token: senderToken ) { success in
                            contentVM.txToShow = success
                            contentVM.showPopOverForTx = true
                            contentVM.sendingWriteTx = false
                        }
                        
                    } label: {
                        Text("Send")
                    }
                    .buttonStyle(.borderedProminent)
                    
                }
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                Divider()
                Text("Receive").font(.title3)
                
                Button(action: {
                    UIPasteboard.general.string = wallet.address
                }, label: {
                    Image(uiImage:profileVM.generateQRCode(from: wallet.address))
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .padding()
                        .frame(width: 230, height: 230)
                })
                    .buttonStyle(.bordered)
                
                    
                
            }.navigationTitle("Crypta Wallet")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                if !reload.shouldReload{
                                    reload.shouldReload = true
                                }
                            }, label: {
                                Image(systemName: "repeat.circle")
                            })

                        }
                    }
                
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(codeTypes: [.qr] ) { response in
                        isShowingScanner = false
                        switch response {
                        case .success(let result):
                            let ethereumAddress = result.string.components(separatedBy: "ethereum:")
                            if ethereumAddress.isEmpty {return}
                            guard let toEthAddress = EthereumAddress(ethereumAddress[1]) else {
                                return
                            }
                            
                            to = toEthAddress.address
                            
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
               
            if profileVM.showProgress{
                ProgressView()
                           .progressViewStyle(CircularProgressViewStyle(tint: Color("Prime")))
                           .scaleEffect(1.5, anchor: .center)
                           .zIndex(1)
                           
            }
        }
        }.alert(item:$profileVM.error) { error in
            Alert(title: Text(error.title), message: Text(error.description), dismissButton: .cancel() {
                contentVM.sendingWriteTx = false
            })
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

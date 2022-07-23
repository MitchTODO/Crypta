//
//  LoginView.swift
//  Crypta
//
//  Created by Mitch on 7/5/22.
//

import SwiftUI

// Check out Stewart video on login https://www.youtube.com/watch?v=QrTChgzseVk&ab_channel=StewartLynch

struct LoginView: View {
    
    @StateObject private var loginVM = LoginViewModel()
    @EnvironmentObject var authentication:Authentication
    
    var body: some View {
        ZStack(alignment: .top) {
            
            VStack(alignment: .center, spacing: 100){
                
                LinearGradient(
                    colors: [.green, .red, .yellow, .blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                    .frame(width: nil, height: 100, alignment: .top)
                    .mask(
                        VStack{
                            Text("Crypta")
                                .font(.largeTitle)
                                .bold()
                                .padding(.bottom)
                            Text("Assist in managing DAOs and (ReFi) projects")
                                .font(.subheadline)
                                .bold()
                                .padding(.bottom)
                        }
                    )
                VStack(spacing: 10) {
                    if(!loginVM.hasKeyStore){
                        Text("Welcome, you must first create a wallet.").font(.title3)
                    }
                    
                    VStack(alignment: .leading,spacing: 10){
                        
                        Text(loginVM.hasKeyStore ? "Password":"New Password")
                            .font(.subheadline)
                            .bold()
                        TextField("",text: $loginVM.credentials.password)
                        
                        
                    }.padding([.leading, .trailing], 20)
                    if loginVM.showProgressView {
                        ProgressView().background(.white)
                    }
                    
                    
                    Button(action: {
                        loginVM.login {success in
                            // Update validation
                            authentication.updateValidation(success: success)
                            
                        }
                        
                    }) {
                        Text(loginVM.hasKeyStore ? "Log in" : "Create new wallet")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 30)
                            .cornerRadius(40)
                    }
                    .padding([.leading, .trailing], 100)
                   
                    
                    Spacer()
                    
                }
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                .alert(item:$loginVM.error) { error in
                    Alert(title: Text("Invalid Login"), message: Text(error.localizedDescription), dismissButton: .cancel())
                }
                VStack {
                    LinearGradient(
                        colors: [.green, .red, .yellow, .blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                        .frame(width: 120, height: 120, alignment: .bottom)
                        .mask(
                            
                            Image("celo")
                                .resizable()
                                .scaledToFit()
                                .aspectRatio(contentMode: .fit)
                                .frame(minWidth: 50, maxWidth: 120, minHeight: 50, maxHeight: 120)
                                .clipShape(Circle())
                                .shadow(color: Color.gray.opacity(0.4),
                                        radius: 3, x: 1, y: 2)
                        )
                    LinearGradient(
                        colors: [.green, .red, .yellow, .blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                        .frame(width: nil, height: 20, alignment: .top)
                        .mask(
                            
                            Text("Sponsored by the CELO network")
                                .font(.headline)
                                .bold()
                            
                        )
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

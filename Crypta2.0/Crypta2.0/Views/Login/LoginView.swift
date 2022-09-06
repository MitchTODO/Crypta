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
            
            VStack(alignment: .center){
                
                LinearGradient(
                    colors: [.green, .red, .yellow, .blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                    .frame(width: nil, alignment: .top)
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
                VStack(spacing: 20) {
                    if(!loginVM.hasKeyStore){
                        Text("Welcome, you must first create a wallet.").font(.title3)
                    }
                    
                    if(loginVM.showProgressView){
                        ProgressView()
                    }
                    
                    VStack(alignment: .leading,spacing: 10){
                        
                        Text(loginVM.hasKeyStore ? "Password":"New Password")
                            .font(.subheadline)
                            .bold()
                        TextField("",text: $loginVM.credentials.password)
                        
                    }.padding([.leading, .trailing], 20)
                    
                    
                    
                    if(!loginVM.mnemonics.isEmpty){
                        
                        VStack(alignment: .leading,spacing: 20){
                            
                            Text("Mnemonics")
                                .font(.subheadline)
                                .bold()
                            
                            Text("Write down your new password and recovery phase.")
                                .frame(height: 50)
                                .font(.body)
                            
                            Text(loginVM.mnemonics)
                                .bold()
                                .lineSpacing(10)
                                .frame(height: 160)
                                .padding([.horizontal], 4)
                                .cornerRadius(5)
                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray))
                             
                        }.padding([.leading, .trailing], 20)
                        
                        Text("This will be the last time this will be shown.")
                            .bold()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .cornerRadius(40)
                        
                        Button(action: {
                            authentication.updateValidation(success: true)
                            
                        }){
                            Text("I understand")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .frame(height: 30)
                                .cornerRadius(40)
                                
                        }.buttonStyle(.borderedProminent)
                        .padding([.leading, .trailing], 20)
                        
                    }else{
                        if(!loginVM.showProgressView) {
                            
                            Button(action: {
                                loginVM.showProgressView = true
                                loginVM.login {success in
                                    print(success)
                                    // Update validation
                                    if loginVM.hasKeyStore {
                                        authentication.updateValidation(success: success)
                                    }
                                }
                                
                            }) {
                                Text(loginVM.hasKeyStore ? "Login" : "Create new wallet")
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .frame(height: 30)
                                    .cornerRadius(40)
                            }
                            .padding([.leading, .trailing], 100)
                        }
                    
                    }
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

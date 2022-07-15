//
//  ContentView.swift
//  Crypta
//
//  Created by Mitch on 7/5/22.
//

import SwiftUI

enum CreationType {
    case group
    case proposal
}

struct ContentView: View {
    @EnvironmentObject var authentication:Authentication
    @ObservedObject var  contentVM = ContentViewModel()
    
    var body: some View {
        NavigationView{
  
            GroupsView().environmentObject(contentVM)
            
                .popover(isPresented: $contentVM.showPopOverForTx){
                    VStack(alignment: .leading, spacing: 20){
                        Text("Tx Details").font(.title)
                        Text(contentVM.txToShow!.transaction.description)
                   }
                }


                .navigationBarTitle(Text("Groups"), displayMode: .inline)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Logout") {
                        authentication.updateValidation(success: false)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(
                        destination: ProfileView().environmentObject(contentVM),
                                    label: {
                                        VStack{
                                            Image(systemName: "creditcard")
                                            //Text("Wallet")
                                        }
                                    })
                }
    
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        switch(contentVM.creationType){
                        case .group:
                            contentVM.popOverGroup.toggle()
                        case .proposal:
                            contentVM.popOverProposal.toggle()
                        
                        }
                        
                    } ) {
                        Image(systemName: "plus.app")
                    }
                }
                 
                // disable toolbar when sending writeTx
            }.disabled(contentVM.sendingWriteTx)
            
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

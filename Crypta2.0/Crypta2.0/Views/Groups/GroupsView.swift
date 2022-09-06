//
//  GroupView.swift
//  Crypta
//
//  Created by Mitch on 7/5/22.
//

import SwiftUI
import web3swift

struct GroupsView: View {
    private var gridItemLayout = [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())]
    
    @StateObject var groupVM = GroupViewModel()
    
    @EnvironmentObject var contentVM:ContentViewModel
    
    @State var newGroup = Group()
    @State var password = ""
    

    var body: some View {
        
        VStack{
   
            ZStack{
                    ScrollView {
                        LazyVGrid(columns: gridItemLayout, spacing: 20) {
                            ForEach((groupVM.groups), id: \.id) { group in
                                NavigationLink(destination: ProposalsView(selectedGroup: group).environmentObject(contentVM),
                                               label:{
                                    VStack{
                                        Image("celo")
                                            .resizable()
                                            .scaledToFit()
                                            .aspectRatio(contentMode: .fit)
                                            .background(Circle().foregroundColor(Color.black))
                                            .frame(minWidth: 50, maxWidth: 70, minHeight: 50, maxHeight: 70)
                                            .clipShape(Circle())
                                            .shadow(color: Color.gray.opacity(0.4),
                                                    radius: 3, x: 1, y: 2)
        

                                        Text(group.name)
                                            .font(.headline)
                                        
                                        Text(group.description)
                                            .font(.subheadline)
                                        
                                    }
                                })
                                
                            }
                        }.disabled(contentVM.sendingWriteTx)
                        
                        if groupVM.showProgress {
                            VStack(spacing:10){
                                ProgressView()
                                           .progressViewStyle(CircularProgressViewStyle(tint: Color("Prime")))
                                           .scaleEffect(1.5, anchor: .center)
                                           .zIndex(1)
                               
                                if groupVM.amountOfGroups == nil {
                                    Text("Fetching the amount of groups...")
                                }else if (!contentVM.sendingWriteTx){
                                    Text("Loading groups...")
                                }else if (contentVM.sendingWriteTx) {
                                    Text("Sending Signed Tx, wait for receipt...")
                                }
                            }
                        }
                    }

                
                .popover(isPresented:  $contentVM.popOverGroup){
                    
                    VStack(alignment: .center, spacing: 20){
                        Text("Create New DAO").font(.title).padding(20)
                        Spacer()
                        
                        Image("celo")
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                            .background(Circle().foregroundColor(Color.black))
                            .frame(minWidth: 50, maxWidth: 100, minHeight: 50, maxHeight: 100)
                            .clipShape(Circle())
                            .shadow(color: Color.gray.opacity(0.4),
                                    radius: 3, x: 1, y: 2)
                        
                        Text("Select DAO Image")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .cornerRadius(16)
                            
                        
                        TextField("Name of group...", text: $newGroup.name)
                            .padding(EdgeInsets(top: 8, leading: 16,
                                                bottom: 8, trailing: 16))
                        
                            .shadow(color: Color.gray.opacity(0.4),
                                    radius: 3, x: 1, y: 2)
                        
                        TextField("Description of group...", text:  $newGroup.description)
                            .padding(EdgeInsets(top: 8, leading: 16,
                                                bottom: 8, trailing: 16))
                        
                            .shadow(color: Color.gray.opacity(0.4),
                                    radius: 3, x: 1, y: 2)
                        Text("Password")
                        TextField("Wallet Password", text: $password)
                            .padding(EdgeInsets(top: 8, leading: 16,
                                                bottom: 8, trailing: 16))
                        
                            .shadow(color: Color.gray.opacity(0.4),
                                    radius: 3, x: 1, y: 2)
                        
                        Button("Create") {
                            
                            contentVM.sendingWriteTx = true // disable list and navibar add
                            contentVM.popOverGroup = false // dimiss popOver
                            
                            // Call create group method in groupViewModel
                            groupVM.createGroup(group: newGroup, password: password) { success in
                                contentVM.txToShow = success
                                contentVM.showPopOverForTx = true
                                contentVM.sendingWriteTx = false
                                password = ""
                            }
                            
                        }.buttonStyle(.borderedProminent)
                        
                        Spacer()
                        
                    }
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    
                }
                
    
            }
        }
        .onAppear{
            contentVM.creationType = .group
            // Update group if group content changed
            if(contentVM.contentChangedForGroup != nil) {
                let index = Int(contentVM.contentChangedForGroup!.id!)
                groupVM.groups[index] = contentVM.contentChangedForGroup!
                contentVM.contentChangedForGroup = nil
            }
        }
        .alert(item:$groupVM.error) { error in
            Alert(title: Text(error.title), message: Text(error.description), dismissButton: .cancel() {
                    contentVM.sendingWriteTx = false
                    password = ""
                })
        }
    }
}

struct GroupsView_Previews: PreviewProvider {
    static var previews: some View {
        GroupsView()
    }
}

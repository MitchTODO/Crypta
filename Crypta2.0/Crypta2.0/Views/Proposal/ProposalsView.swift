//
//  ProposalView.swift
//  Crypta
//
//  Created by Mitch on 7/5/22.
//

import SwiftUI
import web3swift

struct ProposalsView: View {
    
    @StateObject var proposalVM:ProposalViewModel = ProposalViewModel()
    @EnvironmentObject var contentVM:ContentViewModel
    
    @State var selectedGroup:Group
    
    // Creating a new proposal
    @State var newProposal:Proposal = Proposal()
    
    // Choices for proposal
    @State var choiceOne = ""
    @State var choiceTwo = ""
    
    @State var password = ""
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 20 ){
                Image("celo")
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .background(Circle().foregroundColor(Color.black))
                    .frame(minWidth: 50, maxWidth: 100, minHeight: 50, maxHeight: 100)
                    .clipShape(Circle())
                    .shadow(color: Color.gray.opacity(0.4),
                            radius: 3, x: 1, y: 2)
                
                VStack(spacing: 10){
                    Text(selectedGroup.name)
                        .font(.headline)
                    
                    Text(selectedGroup.description)
                        .font(.subheadline)
                    
                    Text("Creator:").font(.subheadline)
                    Text(selectedGroup.creator!.address)
                        .font(.footnote)
                        .truncationMode(.middle)
                        .lineLimit(1)
                    
                    // Disable/Enable a group
                    //contentVM.checkIfCreator(address: selectedGroup.creator!)
                    //if(false){
                    //    HStack{
                    //    TextField("Password",text: $password)
                    //        Button("Disable Group") {
                    //            if(password.isEmpty){return}
                    //            proposalVM.removeGroup(groupId: selectedGroup.id!,password: password) { success in
                    //                contentVM.txToShow = success
                    //                contentVM.showPopOverForTx = true
                    //                contentVM.sendingWriteTx = false
                    //            }
                    //        }.buttonStyle(BorderedButtonStyle())
                    //    }
                    //}
                }
            }
            
            ZStack{
                
                NavigationView {
                    List(proposalVM.proposals,id: \.id) { proposal in
                        NavigationLink(
                            destination: VoteView(groupId: selectedGroup.id!, proposal: proposal, selection: proposal.vote!.hasVoted ? Int(proposal.vote!.indexChoice) : nil ).environmentObject(proposalVM),
                            label: {
                                if proposal.vote!.hasVoted {
                                   
                                    Image(systemName: "checkmark.circle")
                                        .font(.headline)
                                }
                                VStack(spacing: 10){
                                    Text(proposal.title).font(.headline)
                                    Text(proposal.description).font(.subheadline)
                                    if proposal.proposalEnd < NSDate().timeIntervalSince1970 {
                                        Text("Closed").foregroundColor(.red)
                                    }else{
                                        Text("Open").foregroundColor(.green)
                                    }
                                }
                            }
                        ).disabled(contentVM.sendingWriteTx)
                    }.navigationBarTitle("Proposals")
                    
                }.navigationViewStyle(StackNavigationViewStyle())
                
                
                if proposalVM.showProgress {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("Prime")))
                        .scaleEffect(1.5, anchor: .center)
                        .zIndex(1)
                    
                }else if selectedGroup.proposalCount == 0 {
                    Text("No Proposals yet! \nGo create a new proposal.")
                }else if (contentVM.sendingWriteTx) {
                    Text("Sending Signed Tx, wait for receipt...")
                        .zIndex(1)
                }
            }
            
            .onAppear{
                contentVM.creationType = .proposal
            }
            .task {
                
                // Dont load proposals if count is zero or if we have already loaded
                 if selectedGroup.proposalCount != 0 && proposalVM.proposals.count != selectedGroup.proposalCount! {
                    proposalVM.fetchProposals(groupId: Int(selectedGroup.id!),numberOfProposals: Int(selectedGroup.proposalCount!))
                }
            }
            
            // Pop over to write proposal to chain
            .popover(isPresented: $contentVM.popOverProposal){
                VStack(alignment: .center, spacing: 20) {
                    Text("Create new proposal").font(.title)
                    
                    TextField("Title", text: $newProposal.title)
                        .padding(EdgeInsets(top: 8, leading: 16,bottom: 8, trailing: 16))
                        .shadow(color: Color.gray.opacity(0.4),radius: 3, x: 1, y: 2)
                    TextField("Discription", text: $newProposal.description)
                        .padding(EdgeInsets(top: 8, leading: 16,bottom: 8, trailing: 16))
                        .shadow(color: Color.gray.opacity(0.4),radius: 3, x: 1, y: 2)
                    Text("Choices").font(.title3)
                    TextField("Choice One",text: $choiceOne)
                        .padding(EdgeInsets(top: 8, leading: 16,bottom: 8, trailing: 16))
                        .shadow(color: Color.gray.opacity(0.4),radius: 3, x: 1, y: 2)
                    
                    TextField("Choice Two",text: $choiceTwo)
                        .padding(EdgeInsets(top: 8, leading: 16,bottom: 8, trailing: 16))
                        .shadow(color: Color.gray.opacity(0.4),radius: 3, x: 1, y: 2)
                    

                    DatePicker(selection:
                                Binding<Date>(
                                    get: { Date(timeIntervalSince1970: TimeInterval(newProposal.proposalStart)) },
                                    set: { newProposal.proposalStart = $0.timeIntervalSince1970.rounded() }
                                ),
                               displayedComponents: [.date,.hourAndMinute]) { Text("Poll start date").font(.title3) }
                    
                    
                    DatePicker(selection:
                                Binding<Date>(
                                    get: { Date(timeIntervalSince1970: TimeInterval(newProposal.proposalEnd)) },
                                    set: {newProposal.proposalEnd = $0.timeIntervalSince1970.rounded()}
                                ),
                               displayedComponents: [.date,.hourAndMinute]) { Text("Poll end date").font(.title3) }
                    
                    TextField("Wallet Password", text: $password)
                        .padding(EdgeInsets(top: 8, leading: 16,bottom: 8, trailing: 16))
                        .shadow(color: Color.gray.opacity(0.4),radius: 3, x: 1, y: 2)
                    
                    Button("Create Proposal") {
                        contentVM.sendingWriteTx = true
                        contentVM.popOverProposal = false
                        
                        proposalVM.createProposal(groupId: selectedGroup.id!, proposal: newProposal, choiceOne: choiceOne, choiceTwo: choiceTwo, password: password) { success in
                            // reset proposal object
                            newProposal = Proposal()
                            choiceOne = ""
                            choiceTwo = ""
                            //update selectedGroup
                            selectedGroup.proposalCount! += 1
                            // will notify the groups view that group data changed
                            contentVM.contentChangedForGroup = selectedGroup
                            // show tx
                            contentVM.txToShow = success
                            contentVM.showPopOverForTx = true
                            contentVM.sendingWriteTx = false
                        }
                        
                    }
                    
                }.buttonStyle(BorderedButtonStyle())
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                
                
            }
            .multilineTextAlignment(.center)
            .textFieldStyle(.roundedBorder)
            .autocapitalization(.none)
            .disableAutocorrection(true)
        }
        
        .alert(item:$proposalVM.error) { error in
            Alert(title: Text(error.title), message: Text(error.description), dismissButton: .cancel() {
                    contentVM.sendingWriteTx = false
                })
        }
        
        .toolbar {
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(
                    destination: ProfileView().environmentObject(contentVM),
                    label: {
                        VStack{
                            Image(systemName: "person.crop.circle")
                        }
                    })
            }
            
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    
                        contentVM.popOverProposal.toggle()
                    
                } ) {
                    Image(systemName: "plus.app")
                }.disabled(contentVM.sendingWriteTx)
            }
            
            
        }
  
        
    }
}

struct ProposalView_Previews: PreviewProvider {
    static var previews: some View {
        ProposalsView(selectedGroup: Group(id: 0, name: "Test", creator: EthereumAddress("0x48C279b6afbB1074afbA17eB8E461D5232D67aA0")!, description: "Test", image: "", proposalCount: 0, isActive: true))
    }
}

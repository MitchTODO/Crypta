//
//  PollView.swift
//  Crypta
//
//  Created by Mitch on 7/13/22.
//

import SwiftUI
import web3swift
import BigInt

struct VoteView: View {
    
    let groupId:BigUInt
    
    @EnvironmentObject var contentVM:ContentViewModel
    @EnvironmentObject var proposalVM:ProposalViewModel
    
    
    @State var proposal:Proposal
    @StateObject var voteVM = VoteViewModel()
    
    @State var selection:Int?
    @State var password:String = ""
    var body: some View {
        VStack{
            Text(proposal.title).font(.headline)
            Text(proposal.description).font(.subheadline)
            Text(proposal.vote!.hasVoted ? "Your have already Voted." : "")
            
        }
        
        ZStack{
            NavigationView {
                List(voteVM.choices,id: \.id, selection: $selection) { choice in
                    Button {
                        //print("Choice selected \(choice.description)")
                    }label: {
                        HStack {
                            
                            if(proposal.vote!.hasVoted ){
                                Text(choice.votes.description).font(.headline)
                            }
                            Text(choice.description)
                        }
                    }
                }.environment(\.editMode, .constant(EditMode.active))
                .disabled(contentVM.sendingWriteTx || proposal.vote!.hasVoted)
                    
            }
                .navigationViewStyle(.stack)
            
            
            if voteVM.showProgress {
                VStack(spacing:10){
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("Prime")))
                        .scaleEffect(1.5, anchor: .center)
                        .zIndex(1)
                    
                    if voteVM.choices.isEmpty {
                        Text("Fetching choices...")
                    }
                }
            }
        }
        .task{
            // only load
            if(voteVM.choices.isEmpty){
                voteVM.getChoices(groupId: groupId, proposal: proposal)
            }
            
        }
        
        .alert(item:$voteVM.error) { error in
       
            Alert(title: Text(error.title), message: Text(error.description), dismissButton: .cancel() {
                contentVM.sendingWriteTx = false
            })
        }
        
        // Switch between casting and removing vote
            Button(action: {
                voteVM.popOverCredInput = true

            }, label:{
                HStack {
                    Image(systemName: proposal.vote!.hasVoted ? "minus.circle" :"checkmark.circle" )
                        .font(.headline)
                    Text(proposal.vote!.hasVoted ? "Remove Vote" : "Cast Vote")
                        .fontWeight(.semibold)
                        .font(.headline)
                }
                .padding()
                .foregroundColor(.white)
                .background(proposal.vote!.hasVoted ? Color.red : Color.green)
                .cornerRadius(20)
            })
        
        
            .popover(isPresented: $voteVM.popOverCredInput){
                VStack(alignment: .center, spacing: 20){
                    Text("Casting Vote").font(.title)
                    Text("Enter password to cast vote.")
                    TextField("Wallet Password", text: $password)
                        .padding(EdgeInsets(top: 8, leading: 16,bottom: 8, trailing: 16))
                        .shadow(color: Color.gray.opacity(0.4),radius: 3, x: 1, y: 2)
                    Button("Send"){
                        
                        voteVM.popOverCredInput = false
                        contentVM.sendingWriteTx = true
                        
                        if proposal.vote!.hasVoted {
                            // If we have voted then removeVote
                            voteVM.removeVote(groupId: groupId, proposalId: proposal.id!, password: password) { success in
                                proposal.vote!.hasVoted = false
        
                                proposal.vote!.indexChoice = 0
                                proposalVM.proposals[Int(proposal.id!)].vote?.hasVoted = false
                                proposalVM.proposals[Int(proposal.id!)].vote?.indexChoice = 0
                                
                                voteVM.choices[selection!].votes -= 1
                                
                                selection = nil
                                contentVM.txToShow = success
                                contentVM.showPopOverForTx = true
                                contentVM.sendingWriteTx = false
                            }
                            
                        }else{
                            if selection != nil {
                                // Casting vote
                                voteVM.castVote(groupId: groupId, proposalId: proposal.id!, choiceId: selection!, password: "") {success in
                                    proposal.vote!.hasVoted = true
                                    proposal.vote!.indexChoice = BigUInt(selection!)
                                    proposalVM.proposals[Int(proposal.id!)].vote?.hasVoted = true
                                    proposalVM.proposals[Int(proposal.id!)].vote?.indexChoice = BigUInt(selection!)
                                    
                                    voteVM.choices[selection!].votes += 1
                                    
                                    contentVM.txToShow = success
                                    contentVM.showPopOverForTx = true
                                    contentVM.sendingWriteTx = false
                                    
                                }
                            }else{
                                voteVM.error = Web3Services.Web3ServiceError(title: "Option not selected.", description: "Select a poll option.")
                            }
                        }
                        
                    }.buttonStyle(BorderedButtonStyle())
                }
            }
        
    }
}


struct PollView_Previews: PreviewProvider {
    static var previews: some View {
        let wallet = Web3Services.shared.getWallet()
        let address = EthereumAddress(wallet.address)!
        VoteView(groupId: 0,proposal: Proposal(id: 0, title: "Test", description: "Test", creator: address, proposalStart: 0, proposalEnd: 0, choices: []), selection: 0)
    }
}

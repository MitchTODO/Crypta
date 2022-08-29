//
//  ProposalViewModel.swift
//  Crypta
//
//  Created by Mitch on 7/13/22.
//

import Foundation
import BigInt
import web3swift

class ProposalViewModel:ObservableObject {
                      
    @Published var showEventPopOver = false
    @Published var proposals:[Proposal] = []
    
    @Published var showProgress = false
    @Published var error:Web3Services.Web3ServiceError?
    
    // add func to check if proposal has expired

    func removeGroup(groupId:BigUInt,password:String,completion:@escaping(TransactionSendingResult) -> Void) {
        showProgress = true
        let params = [groupId] as [AnyObject]
 
        Web3Services.shared.writeContractMethod(method: .disableGroup, parameters: params,password: password ){
            result in
            DispatchQueue.main.async { [unowned self] in
                showProgress = false
                switch(result) {
                case .success(let tx):
                    completion(tx)
                case .failure(let error):
                    self.error = Web3Services.Web3ServiceError(title: "Failed to remove group.", description: error.errorDescription)
                    
                }
            }
        }
    }
    
    
    // fetch events based on groupId
    func fetchProposals(groupId:Int,numberOfProposals:Int) {
        showProgress = true
        let params = [groupId,0,numberOfProposals] as [AnyObject]
        
        Web3Services.shared.readContractMethod(method: .getProposals, parameters: params) {
            result in
            DispatchQueue.main.async { [unowned self] in
                showProgress = false
                switch(result) {
                case .success(let value):
             
                    let proposalList = value["0"] as! Array<Any>
                    let voteList = value["1"] as! Array<Any>
                    
                    var allProposals:[Proposal] = []
                    
                    for (index,element) in proposalList.enumerated() {
                        let voteObject = voteList[index] as! Array<Any>
                        
                        let boolFromInt = voteObject[0] as! Bool
                    
                        let choiceIndex = voteObject[1] as! BigUInt
                        let vote = Vote(hasVoted: boolFromInt, indexChoice: choiceIndex)
                        
                        let data = element as! Array<Any>
                        let id = data[0] as! BigUInt
                        let groupId = data[1] as! BigUInt
                        let title = data[2] as! String
                        let description = data[3] as! String
                        let creator = data[4] as! EthereumAddress
                        // Epoch time in seconds
                        let proposalStart = data[5] as! BigUInt
                        let proposalEnd = data[6] as! BigUInt
                        
                        
                        let proposal = Proposal(id: id, title:title , description: description, creator: creator, proposalStart: TimeInterval(Int(proposalStart)), proposalEnd: TimeInterval(Int(proposalEnd)), choices: [], vote: vote)
                        allProposals.append(proposal)
                        
                    }
                    proposals.append(contentsOf: allProposals)
                case .failure(let error):
                    self.error = Web3Services.Web3ServiceError(title: "Failed to get proposals.", description: error.errorDescription)
                    
                }
            }
        }
    }
    
    func createProposal(groupId:BigUInt,proposal:Proposal,choiceOne:String,choiceTwo:String ,password:String, completion:@escaping(TransactionSendingResult) -> Void){
        showProgress = true
        let startTime = Int(proposal.proposalStart)
        let endTime = Int(proposal.proposalEnd)
        
        let params = [groupId,proposal.title,proposal.description,startTime,endTime,[[0,choiceOne],[0,choiceTwo]]] as [AnyObject]
     
        Web3Services.shared.writeContractMethod(method: .createProposal, parameters: params, password:password ) {
            result in
            DispatchQueue.main.async { [unowned self] in
                showProgress = false
                switch(result) {
                case .success(let tx):
                    // Tx was successful, update proposal and add to proposals
                    var proposal = proposal
                    proposal.id = BigUInt(proposals.count)
                    proposal.vote = Vote(hasVoted: false, indexChoice: BigUInt(0))
                    proposals.append(proposal)
                    completion(tx)
                case .failure(let txError):
                    self.error = Web3Services.Web3ServiceError(title: "Failed to create proposal.", description: txError.errorDescription)
       
                }
            }
        }
    }
       
    
}

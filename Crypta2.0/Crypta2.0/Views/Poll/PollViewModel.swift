//
//  PollViewModel.swift
//  Crypta
//
//  Created by Mitch on 7/13/22.
//

import Foundation
import SwiftUI
import BigInt
import web3swift

class PollViewModel:ObservableObject{
    
    @Published var choices:[Choice] = []
    @Published var showProgress = false
    @Published var error:CryptaError?
    @Published var popOverCredInput = false
    

    func getChoices(groupId:BigUInt,proposal:Proposal)  {
        let params = [groupId,proposal.id] as [AnyObject]
     
        showProgress = true
        Web3Services.shared.readContractMethod(method: .getChoice, params:params){
            result in
            DispatchQueue.main.async { [unowned self] in
                showProgress = false
                switch(result) {
                case .success(let value):
                    let choicesArray = value["0"] as! Array<Any>
                    var allChoices:[Choice] = []
                    var indexId = 0
        
                    for choiceObject in choicesArray {
                        
                        let data = choiceObject as! Array<Any>
                        let votes = data[0] as! BigUInt
                        let title = data[1] as! String
                        
                        let id = indexId
                        indexId += 1 // incament id
                        
                        let choice = Choice(id:id,votes: votes, description: title, selected: proposal.vote!.hasVoted)
                        
                        allChoices.append(choice)
                    }
                    
                    choices.append(contentsOf: allChoices)
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    /*
     Bug found within the web3swift pod
     
     When attempting to cast a vote twice, contract method reverts.
     Web3swift treats this as a processing error (watch it is) but with the incorrect statement
     This only occurs with sending a write tx
     
     - Returns
     ** Incorrect
            Failed to fetch gas estimate
     ** Correct
            You have already voted.
     */
    
    // TODO create callback for proposalVM vote updates
    func castVote(groupId:BigUInt,proposalId:BigUInt,choiceId:Int,password:String,completion:@escaping(TransactionSendingResult) -> Void) {
        let params = [groupId,proposalId,choiceId] as [AnyObject]
        showProgress = true
        
        Web3Services.shared.writeContractMethod(method: .vote, params: params,password:password) {
            result in
            DispatchQueue.main.async { [unowned self] in
                showProgress = false
                switch(result){
                case .success(let tx):
                    completion(tx)
                case .failure(let txError):
                    if txError.errorDescription == "Failed to fetch gas estimate"{
                        let error = CryptaError(description: "You have already voted.")
                        self.error = error
                    }else{
                        self.error = CryptaError(description: txError.errorDescription)
                    }
                }
            }
        }
    }
    
    func removeVote(groupId:BigUInt,proposalId:BigUInt,password:String,completion:@escaping(TransactionSendingResult) -> Void) {
        let params = [groupId,proposalId] as [AnyObject]
        showProgress = true

        Web3Services.shared.writeContractMethod(method: .removeVote, params: params,password:password ) {
            result in
            DispatchQueue.main.async { [unowned self] in
                showProgress = false
                switch(result){
                case .success(let tx):
                    completion(tx)
                case .failure(let txError):
                    if txError.errorDescription == "Failed to fetch gas estimate"{
                        let error = CryptaError(description: "You have already remoted your vote.")
                        self.error = error
                    }else{
                        self.error = CryptaError(description: txError.errorDescription)
                    }
                }
            }
        }
    }
    
    
}

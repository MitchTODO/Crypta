//
//  ContentViewModel.swift
//  Crypta
//
//  Created by Mitch on 7/14/22.
//

import Foundation
import web3swift


class ContentViewModel:ObservableObject {
    
    @Published var credentials = Credentials()
    
    @Published var showPopOverForTx = false
    @Published var txToShow:TransactionSendingResult?
    
    @Published var sendingWriteTx = false
    
    // Creating new group or proposal
    @Published var isCreating = false
    @Published var creationType:CreationType = .group
    
    @Published var popOverProposal = false
    @Published var popOverGroup = false
    

    func checkIfCreator(address:EthereumAddress) -> Bool {
        return(Web3Services.shared.getWallet().address == address.address)
    }

    

       
    
    
}

//
//  Groups.swift
//  Crypta
//
//  Created by Mitch on 7/9/22.
//

import Foundation

/*
 Note:
 Had my contract open along side Xcode to create enum with contract methods.
 If your not sure what methods are callable copy and paste your contract into https://remix.ethereum.org/
 Method name MUST match the method in the contract ABI
 */

enum ContractMethods:String {
    case createProposal = "createProposal"
    case getProposalCount = "getProposalCount"
    case getProposals = "getProposals"
    case getProposal = "getProposal"
    
    case getChoice = "getChoice"
    
    case vote = "vote"
    case getVote = "getVote"
    case removeVote = "removeVote"
    
    
    case newGroup = "newGroup"
    case getGroup = "getGroup"
    case disableGroup = "disableGroup"
    case activateGroup = "activateGroup"
    // This is a public variable not method but still callable
    case groupIdTracker = "groupIdTracker"
}

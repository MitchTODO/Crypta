//
//  Proposal.swift
//  Crypta
//
//  Created by Mitch on 7/12/22.
//

import Foundation
import BigInt
import web3swift

// MARK: Proposal
struct Proposal {
    
    var id:BigUInt?
    var title = ""
    var description = ""
    var creator:EthereumAddress?
    var proposalStart:TimeInterval = Date().timeIntervalSince1970
    var proposalEnd:TimeInterval = Date().timeIntervalSince1970
    var choices:[Choice] = [] // contract only allows five choices
    var vote:Vote?
}
 

// MARK: Choice
struct Choice {
    var id:Int
    var votes:BigUInt
    var description:String
    var selected:Bool
}

// MARK: Vote
struct Vote {
    var hasVoted:Bool
    var indexChoice:BigUInt
}

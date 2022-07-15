//
//  Group.swift
//  Crypta
//
//  Created by Mitch on 7/5/22.
//

import Foundation
import web3swift
import BigInt

struct Group {
    var id:BigUInt?
    var name:String = ""
    var creator:EthereumAddress?
    var description:String = ""
    var image:String = ""
    var proposalCount:BigUInt?
    var isActive:Bool?
}

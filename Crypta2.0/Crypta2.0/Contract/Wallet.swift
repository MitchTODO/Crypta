//
//  Wallet.swift
//  Crypta
//
//  Created by Mitch on 7/6/22.
//

import Foundation

// MARK: Wallet
/// Recommended struct for wallet object
/// Docs https://github.com/skywinder/web3swift/blob/develop/Documentation/Usage.md#preferred-keys-wallet-model-account
struct Wallet {
    let address: String
    let data: Data
    let name:String
    let isHD:Bool
}

//
struct HDKey {
    let name:String?
    let address:String
}

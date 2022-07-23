//
//  Tokens.swift
//  Crypta
//
//  Created by Mitch on 7/14/22.
//

import Foundation
import UIKit
import web3swift
/// Taken from the Celo Docs https://docs.celo.org/token-addresses

let CELO = ERC20Token(name: "Celo Native Asset", address: "0xF194afDf50B03e69Bd7D057c1Aa9e10c9954E4C9", decimals: "18", symbol: "CELO")
let cUSD = ERC20Token(name: "Celo Dollar", address: "0x874069fa1eb16d44d622f2e0ca25eea172369bc1" , decimals: "18", symbol: "cUSD")
let cEUR = ERC20Token(name: "Celo Euro", address: "0x10c892a6ec43a53e45d0b916b4b7d383b1b78c0f", decimals: "18", symbol: "cEUR")
let cREAL = ERC20Token(name: "REAL", address: "0xC5375c73a627105eb4DF00867717F6e301966C32", decimals: "18", symbol: "cREAL")

// Pulled from https://github.com/skywinder/web3swift/blob/develop/Documentation/Usage.md#get-erc20-token-balance

// MARK: ERC20Token
/// Celo tokens are erc20 compliant but not ERC-20 tokens.
/// Celo tokens have way more functionally.
/// Check out the differences https://docs.celo.org/developer-guide/celo-for-eth-devs
struct ERC20Token {
    var name: String
    var address: String
    var decimals: String
    var symbol: String
}

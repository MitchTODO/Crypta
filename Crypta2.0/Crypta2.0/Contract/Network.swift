//
//  Network.swift
//  Crypta
//
//  Created by Mitch on 7/14/22.
//

import Foundation
import BigInt

/// Helpful docs
/// Celo networks https://docs.celo.org/getting-started/choosing-a-network
/// https://docs.celo.org/developer-guide/forno
/// web3swift https://github.com/skywinder/web3swift/blob/develop/Documentation/Usage.md#web3-instance

let alfajoresTestnet = Network(chainId: BigUInt(44787) , rpcEndpoint: "https://alfajores-forno.celo-testnet.org")
let webSocketURI = "wss://alfajores-forno.celo-testnet.org/ws"

// Mainnet
let mainnet = Network(chainId: BigUInt(42220), rpcEndpoint: "https://explorer.celo.org/api/eth-rpc")


struct Network {
    let chainId:BigUInt
    let rpcEndpoint:String
}

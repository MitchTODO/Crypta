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
/// web3swift https://github.com/skywinder/web3swift/blob/develop/Documentation/Usage.md#web3-instance

let alfajoresTestnet = Network(chainId: BigUInt(44787) , rpcEndpoint: "https://alfajores-forno.celo-testnet.org")
let mainnet = Network(chainId: BigUInt(42220), rpcEndpoint: "https://explorer.celo.org/api/eth-rpc")

struct Network {
    let chainId:BigUInt
    let rpcEndpoint:String
}

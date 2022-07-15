//
//  Web3Errors.swift
//  Crypta
//
//  Created by Mitch on 7/11/22.
//

import Foundation

// MARK: CryptaError
// Used as a formatter for web3swift Web3Error
struct CryptaError:Error,LocalizedError,Identifiable {
    var id:String {description}
    let description:String

}


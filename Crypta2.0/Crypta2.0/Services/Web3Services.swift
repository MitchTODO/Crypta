//
//  Web3Services.swift
//  Crypta

//
//  Created by Mitch on 7/6/22.
//

import Foundation
import web3swift
import BigInt

// MARK: Web3Services
/// Guts of interacting with are contract and other chain data
/// For more info about these methods check out web3swift docs
/// https://github.com/skywinder/web3swift/blob/develop/Documentation/Usage.md#get-balance
///
class Web3Services {
    
    static let shared = Web3Services()
    
    private var w3:web3
    private let cryptaWallet:Wallet
    
    
    init(){
        let keystore = KeyStoreServices.shared.keystoreManager!
  
        let name = "Crypta Wallet"
        let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
        let address = keystore.addresses!.first!.address
        let wallet = Wallet(address: address, data: keyData, name: name, isHD: false)
        // add wallet data to keystoreManager
        let keystoreManager = KeystoreManager([keystore])
        self.cryptaWallet = wallet // set wallet
        
        // Set up provider ie alfajores testnet
        let provider = Web3HttpProvider(URL(string: alfajoresTestnet.rpcEndpoint)!, network: .Custom(networkID: alfajoresTestnet.chainId))
        w3 = web3(provider:provider!)
        
        // add keystoreManager to web3 object
        w3.addKeystoreManager(keystoreManager)
    }
    
    
    struct Web3ServiceError:Error,LocalizedError,Identifiable {
        var id:String {description}
        let title:String
        let description:String
    }
    
    
    // MARK: getWallet
    /// Returns wallet struct
    func getWallet() -> Wallet {
        return self.cryptaWallet
    }
    

    // MARK: readContractMethod
    /// Async method to read contract data.

    /// - Note: Read data from contract is free unlike `writeContractMethod`.
    /// - Parameter method: ContractMethods variable represents the contract method to call.
    /// - Parameter parameters: parameters for contract method.
    /// - Returns: Escaping result.
    ///                 < Success: [String:Any], Failure: Web3Error >
    ///
    
    func readContractMethod(method:ContractMethods,parameters:[AnyObject],completion:@escaping(Result<[String:Any],Web3Error>) -> Void) {
        DispatchQueue.global().async{ [unowned self] in
            do{
                
                let senderAddress = EthereumAddress(cryptaWallet.address)
                let contractAddress = EthereumAddress(contractAddress)
                
                let extraData: Data = Data() // Extra data for contract method
                let contract = w3.contract(contractABI, at: contractAddress, abiVersion: abiVersion)!
                
                var options = TransactionOptions.defaultOptions
               
                options.from = senderAddress
                options.gasPrice = .automatic
                options.gasLimit = .automatic
                
                //
                let tx = contract.read(method.rawValue,
                                       parameters: parameters,
                                       extraData: extraData,
                                       transactionOptions: options)!
                
                
                let result = try tx.call()
                
                completion(.success(result))
            }catch {
                completion(.failure(error as! Web3Error))
            }
        }
    }
    
    // MARK: readContractMethod
    /// Async method to read contract data.

    /// - Note: Adjustable contract parameters work great for fetching token balances.
    /// - Parameter contractAddress:String of contract address.
    /// - Parameter contractABI: String of contract abi.
    /// - Parameter method: String of contract method to call (Must match contract ABI)
    /// - Parameter parameters: List of AnyObject's used for parameters of contract method .
    /// - Returns: Escaping result.
    ///                 < Success: [String:Any], Failure: Web3Error >
    ///
    func readContractMethod(contractAddress:String, contractABI:String, method:String,parameters:[AnyObject],completion:@escaping(Result<[String:Any],Web3Error>) -> Void) {
        DispatchQueue.global().async{ [unowned self] in
            do{
                
                let senderAddress = EthereumAddress(cryptaWallet.address)
                let contractAddress = EthereumAddress(contractAddress)
                
                let extraData: Data = Data() // Extra data for contract method
                let contract = w3.contract(contractABI, at: contractAddress, abiVersion: abiVersion)!
                
                var options = TransactionOptions.defaultOptions
               
                options.from = senderAddress
                options.gasPrice = .automatic
                options.gasLimit = .automatic
                
                let tx = contract.read(method,
                                       parameters: parameters,
                                       extraData: extraData,
                                       transactionOptions: options)!
                
                let result = try tx.call()
                
                completion(.success(result))
            }catch {
                completion(.failure(error as! Web3Error))
            }
        }
    }
    
    // MARK: writeContractMethod
    /// Async method to write contract data  // Called when data is being written to the contract or on chain
    ///
    /// - Note: This requires keystore password as the tx need to be signed by the private key
    /// - Parameter method: ContractMethods enum, contract method to call (Using the rawValue String)
    /// - Parameter parameters:list of Any objects used for input for contract method
    /// - Parameter password: String password that was used to create the keystore (ie encrypt the privatekey)
    /// - Returns: Escaping Result.
    ///                     <Success: TransactionSendingResult, Failure: Web3Error>
    ///
    func writeContractMethod(method:ContractMethods,parameters:[AnyObject],password:String,completion:@escaping(Result<TransactionSendingResult,Web3Error>) -> Void) {
        DispatchQueue.global().async{ [unowned self] in
            do{
                
                let senderAddress = EthereumAddress(cryptaWallet.address)
                let contractAddress = EthereumAddress(contractAddress)

                // if your contract method is payable then you can also send value
                //let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
                let extraData: Data = Data() // Extra data for contract method
                let contract = w3.contract(contractABI, at: contractAddress, abiVersion: abiVersion)!
                
                var options = TransactionOptions.defaultOptions
                //options.value = amount // Only needed if sending native coin not token
                options.from = senderAddress
                options.gasPrice = .automatic
                options.gasLimit = .automatic
                
                let tx = contract.write(
                    method.rawValue,
                    parameters: parameters,
                    extraData: extraData,
                    transactionOptions: options)!
                
                let result = try tx.send(password: password)
                completion(.success(result))
            }catch {
                completion(.failure(error as! Web3Error))
                
            }
        }
    }
    
    // MARK: writeContractMethod
    /// Async method to write contract data
    ///
    ///
    /// - Note: This requires keystore (Wallet) password as the tx need to be signed by the private key
    /// - Parameter contractAddress:String of contract address.
    /// - Parameter contractABI: String of contract abi.
    /// - Parameter method: String of contract method to call (Must match contract ABI)
    /// - Parameter parameters:list of Any objects used for input for contract method
    /// - Parameter password: String password that was used to create the keystore (ie encrypt the privatekey)
    /// - Returns: Escaping Result.
    ///                     <Success: TransactionSendingResult, Failure: Web3Error>
    ///
    func writeContractMethod(contractAddress:String,contractABI:String,method:String,parameters:[AnyObject],password:String,completion:@escaping(Result<TransactionSendingResult,Web3Error>) -> Void) {
        DispatchQueue.global().async{ [unowned self] in
            do{
                
                let senderAddress = EthereumAddress(cryptaWallet.address)
                let contractAddress = EthereumAddress(contractAddress)

                // if your contract method is payable then you can also send value
                //let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
                let extraData: Data = Data() // Extra data for contract method
                let contract = w3.contract(contractABI, at: contractAddress, abiVersion: abiVersion)!
                
                var options = TransactionOptions.defaultOptions
                options.from = senderAddress
                options.gasPrice = .automatic
                options.gasLimit = .automatic
                
                let tx = contract.write(
                    method,
                    parameters: parameters,
                    extraData: extraData,
                    transactionOptions: options)!
                
                let result = try tx.send(password: password)
                completion(.success(result))
            }catch {
                completion(.failure(error as! Web3Error))
                
            }
        }
    }
    
}

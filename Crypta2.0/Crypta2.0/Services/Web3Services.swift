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
        // Create wallet struct from keystore
        let keystore = KeyStoreServices.shared.getKeyStore()!
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
    
    // MARK: getWallet
    // returns wallet struct
    func getWallet() -> Wallet {
        return self.cryptaWallet
    }
    
    // MARK: getTokenBalance
    // Note: This function is kept for demo purposes.
    /// This function can merge with readContractMethod, as it is a read tx
    func getTokenBalance(token:ERC20Token, completion:@escaping(Result<String,Web3Error>) -> Void) {
        DispatchQueue.global().async{ [unowned self] in
            do{
                let walletAddress = EthereumAddress(cryptaWallet.address)
                let erc20ContractAddress = EthereumAddress(token.address)
                let contract = w3.contract(Web3.Utils.erc20ABI, at: erc20ContractAddress, abiVersion: 2)!
                var options = TransactionOptions.defaultOptions
                options.from = walletAddress
                options.gasPrice = .automatic
                options.gasLimit = .automatic
                let method = "balanceOf"
                let tx = contract.read(
                    method,
                    parameters: [walletAddress] as [AnyObject],
                    extraData: Data(),
                    transactionOptions: options)!
                let tokenBalance = try tx.call()
                let balanceBigUInt = tokenBalance["0"] as! BigUInt
                let balanceString = Web3.Utils.formatToEthereumUnits(balanceBigUInt, toUnits: .eth, decimals: 3)!
                completion(.success(balanceString))
            } catch {
                completion(.failure(error as! Web3Error))
            }
        }
    }
    
    // MARK: readContractMethod
    // Async method to read contract data
    // This function is free to call unlike writeContractMethod
    // PARAM:
    // method: ContractMethods contract method to call (Only using the rawValue String)
    // params: used for input for contract method
    func readContractMethod(method:ContractMethods,params:[AnyObject],completion:@escaping(Result<[String:Any],Web3Error>) -> Void) {
        DispatchQueue.global().async{ [unowned self] in
            do{
                
                let walletAddress = EthereumAddress(cryptaWallet.address)
                let contractAddress = EthereumAddress(contractAddress)
                let contractMethod = method.rawValue
                
                let extraData: Data = Data() // Extra data for contract method
                let contract = w3.contract(contractABI, at: contractAddress, abiVersion: abiVersion)!
                
                var options = TransactionOptions.defaultOptions
               
                options.from = walletAddress
                options.gasPrice = .automatic
                options.gasLimit = .automatic
                
                let tx = contract.read(contractMethod, parameters: params, extraData: extraData, transactionOptions: options)!
                
                let result = try tx.call()
                
                completion(.success(result))
            }catch {
                // Web3Error Type conforms to Error Type
                completion(.failure(error as! Web3Error))
            }
        }
    }
    
    // MARK: writeContractMethod
    // Called when data is being written to the contract or on chain
    // This requires keystore password as the tx need to be signed by the private key
    // PARAMS:
    // method: ContractMethods enum, contract method to call (Using the rawValue String)
    // params: list of Any objects used for input for contract method
    // password: string password that was used to create the keystore (ie encrypt the privatekey)
    func writeContractMethod(method:ContractMethods,params:[AnyObject],password:String,completion:@escaping(Result<TransactionSendingResult,Web3Error>) -> Void) {
        DispatchQueue.global().async{ [unowned self] in
            do{
                
                let walletAddress = EthereumAddress(cryptaWallet.address)
                let contractAddress = EthereumAddress(contractAddress)
                let contractMethod = method.rawValue
                // if your contract method is payable then you can also send value
                //let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
                let extraData: Data = Data() // Extra data for contract method
                let contract = w3.contract(contractABI, at: contractAddress, abiVersion: abiVersion)!
                
                var options = TransactionOptions.defaultOptions
                //options.value = amount
                options.from = walletAddress
                options.gasPrice = .automatic
                options.gasLimit = .automatic
                
                let tx = contract.write(
                    contractMethod,
                    parameters: params,
                    extraData: extraData,
                    transactionOptions: options)!
                
                let result = try tx.send(password: password)
                completion(.success(result))
            }catch {
                completion(.failure(error as! Web3Error))
                
            }
        }
    }
    
    // MARK: sendTokens
    // Async method Sends erc20 compliant tokens like CELO
    // PARAMS
    // token: token object contains relivate info to send
    // value: amount of tokens to send in wei base 18
    // to: String address the reciver of the token
    // password: string password of senders keystore 
    func sendTokens(token:ERC20Token,value:String,to:String,password:String,completion:@escaping(Result<TransactionSendingResult,Web3Error>) -> Void) {
        DispatchQueue.global().async{ [unowned self] in
            do{
                let walletAddress = EthereumAddress(cryptaWallet.address) // your wallet
                let toAddress = EthereumAddress(to)!
                
                let erc20ContractAddress = EthereumAddress(token.address)!
                let contract = w3.contract(Web3.Utils.erc20ABI, at: erc20ContractAddress, abiVersion: 2)!
                let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
                var options = TransactionOptions.defaultOptions
                //options.value = amount
                options.from = walletAddress
                options.gasPrice = .automatic
                options.gasLimit = .automatic
                
                let method = "transfer"
                let tx = contract.write(
                    method,
                    parameters: [toAddress, amount] as [AnyObject],
                    extraData: Data(),
                    transactionOptions: options)!
                let result = try tx.send(password: password)
                completion(.success(result))
            }catch {
                completion(.failure(error as! Web3Error))
                
            }
        }
    }
    
    
    
}

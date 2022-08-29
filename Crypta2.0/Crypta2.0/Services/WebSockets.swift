//
//  WebSockets.swift
//  Crypta2.0
//
//  Created by Mitch on 7/19/22.
//

import Foundation
import web3swift
import UIKit
import BigInt



// MARK: - Welcome
struct SocketMessage: Codable {
    let jsonrpc, method: String
    let params: SocketParams
}

// MARK: - Params
struct SocketParams: Codable {
    let subscription: String
    let result: SocketResult
}

// MARK: - Result
struct SocketResult: Codable {
    let address: String
    let topics: [String]
    let data, blockNumber, transactionHash, transactionIndex: String
    let blockHash, logIndex: String
    let removed: Bool
}


// MARK: WebSockets
/// Connects and subscribes to events emitted by the smart contract

class WebSockets:Web3SocketDelegate,ObservableObject {
    // {"jsonrpc":"2.0","id":1,"result":"0x948b48a1cc95a23b757cee5ab832b93c"}
    struct Subscription: Codable {
        let jsonrpc, result: String
        let id:Int
    }
    struct Unsubscribe:Codable{
        let jsonrpc: String
        let result: Bool
        let id:Int
    }
    
    enum SubscriptionState {
        case none
        case subscribed
        case unsubscribed
    }
    
    
    @Published var subscriptionState = SubscriptionState.none
    
    @Published var newEvent = false
    @Published var eventTitle:String = ""
    
    private var socketProvider:WebsocketProvider? = nil
    //private var contract:EthereumContract? = nil
    private var subscription:Subscription? = nil
    
    init() {
        // Create and connect socket
        socketProvider = WebsocketProvider(webSocketURI, delegate: self)
        socketProvider!.connectSocket()
        // The ethereumContract should be able to decode the log data, but it doesn't
        //contract = EthereumContract(contractABI, at: EthereumAddress(contractAddress)!)!
    }
    
    // MARK: disconnectSocket
    ///  Unsubscribes the the socket using the subscription id as parameter
    func disconnectSocket() {
        let ethUnsubscribe =
                    """
                        {"jsonrpc":"2.0", "id": 1, "method": "eth_unsubscribe", "params": ["\(subscription!.result)"]}
                    """
        subscriptionState = .unsubscribed
        socketProvider!.socket.write(string: ethUnsubscribe)
    }
    
    // MARK: socketConnected
    /// Writes to the socket when connected
    /// Only subscribing to contract logs, that includes emitted events
    /// For more subscription request params https://docs.infura.io/infura/networks/ethereum/json-rpc-methods/subscription-methods/eth_subscribe
    func socketConnected(_ headers: [String : String]) {
        let ethSubscribe =
                    """
                            {"jsonrpc":"2.0", "id": 1, "method": "eth_subscribe", "params": ["logs", {"address": "\(contractAddress)" } ]}
                    """
        socketProvider!.socket.write(string: ethSubscribe)
    }
    
    // MARK: received
    /// Receives messages from the socket provider
    func received(message: Any) {
        
        let stringMessage = message as! String
        let data = Data(stringMessage.utf8)
        let decoder = JSONDecoder()
        do {
            switch(subscriptionState){
            case .none:
                // Need to receive are subscription id
                subscription = try decoder.decode(Subscription.self, from: data)
                subscriptionState = .subscribed
            case .subscribed:
                // We are subscribed, must be events
                let event = try decoder.decode(SocketMessage.self, from: data)
                handleEvent(message: event)
            case .unsubscribed:
                // unsubscribed is set during disconnecting, decode successful message
                let unsubscribed = try decoder.decode(Unsubscribe.self, from: data)
                if unsubscribed.result {
                    socketProvider!.socket.disconnect()
                }
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func gotError(error: Error) {
        print("Got error \(error)")
    }
    
    // MARK: handleEvent
    /// TODO: Decode the log data
    func handleEvent(message:SocketMessage) {
        
        /// hex identifier 0x
        //let hexString = jsonMessage.params.result.data.dropFirst(2)
        //let arrayHex = Array(hexString)
        /// First 64 bytes are groupId
        //let groupIdRange: ClosedRange = 0...63
        
        // Using topic to id the event type
        switch(message.params.result.topics.first) {
            
        case Topics.newProposal.rawValue:
            
            //let idRange: ClosedRange = 64...127
            //let groupId = BigUInt(String(arrayHex[groupIdRange]))
            //let id = BigUInt(String(arrayHex[idRange]))
            
            newEvent = true
            eventTitle = "A new proposal has been created."
            
        case Topics.newGroup.rawValue:
            //let groupId = BigUInt(String(arrayHex[groupIdRange]))
            
            newEvent = true
            eventTitle = "A new group has been created."
        default:
            print("Unkown Topic")
            
        }
    }
}


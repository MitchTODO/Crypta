//
//  GroupViewModel.swift
//  Crypta
//
//  Created by Mitch on 7/13/22.
//

import Foundation
import web3swift
import BigInt
import SwiftUI

class GroupViewModel:ObservableObject {
    
    @Published var credentials = Credentials()
    
    // Amount of groups and the groups array
    @Published var amountOfGroups:BigUInt?
    @Published var groups:[Group] = []
    
    @Published var error:Web3Services.Web3ServiceError?
    
    @Published var showProgress = false
    
    private var batchSize = 10
    
    @Published var selectedGroup:Group?
    @Published var presentCredInput = false
    
    init() {
        // First get the amount of groups that exist
        groupAmount()
    }
   
    // MARK: createGroup
    /// Creates new group
    ///
    /// - Note: Doesn't emit a failing escaping result. Instead we set the binding error varaible that will display the error to user.
    ///
    /// - Parameters:
    ///                 - `group`: group struct that will be created
    ///                 - `password` : password of sender that will create the group
    ///
    /// - Returns: Escaping Result.
    ///           <Success: TransactionSendingResult>
    ///
    func createGroup(group:Group,password:String,completion:@escaping(TransactionSendingResult) -> Void) {
        showProgress = true
        
        let params = [group.name,group.description,group.image] as [AnyObject]
        //(method: .newGroup, params: params, password: password)
        Web3Services.shared.writeContractMethod(method:.newGroup, parameters: params, password: password){
            result in
            // Update UI on main thread
            DispatchQueue.main.async { [unowned self] in
                showProgress = false
        
                switch(result) {
                case .success(let tx):
                    
                    let group = Group(id: BigUInt(groups.count), name: group.name, creator: tx.transaction.sender!, description: group.description, image: "", proposalCount: 0, isActive: true)
                    groups.append(group)
                    
                    completion(tx)
                case .failure(let txError):
                    // if web3Error use txError.errorDescription
                    self.error = Web3Services.Web3ServiceError(title: "Failed to create group.", description: txError.errorDescription)
                }
            }
        }
    }
    
    // MARK:
    // Returns int amount of groups
    func groupAmount() {
        showProgress = true
        let params = [] as [AnyObject]
        Web3Services.shared.readContractMethod( method: .groupIdTracker, parameters: params){
            result in
            DispatchQueue.main.async { [unowned self] in
                
                switch(result) {
                    
                case .success(let value):
                    let resObject = value["0"]! as! BigUInt
                    amountOfGroups = resObject
                    
                    fetchGroups()
                case .failure(let error):
                    
                    self.error = Web3Services.Web3ServiceError(title: "Failed to get group amount.", description: error.errorDescription)
                }
            }
        }
    }
    
    // MARK: fetchGroups
    // fetchs groups in batches
    // Add groups to the class groups Array
    func fetchGroups() {
        showProgress = true
        if amountOfGroups == nil {
            print("Failed to fetch groups")
            return
        }
        
        if amountOfGroups == 0 {
            print("No groups exist")
            showProgress = false
            return
        }
   
        let params = [0, amountOfGroups] as [AnyObject]

        Web3Services.shared.readContractMethod(method: .getGroup, parameters: params) {
            result in
            DispatchQueue.main.async { [unowned self] in
                showProgress = false
                switch(result) {
                case .success(let value):
                    var allGroups:[Group] = []
                    
                    let groupArray = value["0"] as! Array<Any>
                    
                    for g in groupArray {
  
                        let data = g as! Array<Any>
                        
                        let id = data[0] as! BigUInt
                        let name = data[1] as! String
                        let creator = data[2] as! EthereumAddress
                        let description = data[3] as! String
                        let image = data[4] as! String
                        let numberOfProposals = data[5] as! BigUInt
                        
                        let literBool = data[6] as! Int
                        let isActive = Bool(truncating: literBool as NSNumber)
                        
                        let newG = Group(id:id, name: name, creator: creator, description: description, image: image, proposalCount: numberOfProposals, isActive: isActive)
                        allGroups.append(newG)
                        
                    }
                    
                    // Only update once when loop is done
                    groups.append(contentsOf: allGroups)
                    
                case .failure(let error):
                    self.error = Web3Services.Web3ServiceError(title: "Failed to get groups.", description: error.errorDescription)
    
                }
                
            }
        }
    }

}

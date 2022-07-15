//
//  LoginViewModel.swift
//  Crypta
//
//  Created by Mitch on 7/5/22.
//

import Foundation
import web3swift

class LoginViewModel:ObservableObject {
    @Published var credentials = Credentials()
    @Published var showProgressView = false
    @Published var error:Authentication.AuthenticationError?
    
    @Published var hasKeyStore = false
    
    private var keyStore:EthereumKeystoreV3?
    
    
    init() {

            let path = FileManager.default.urls(for: .documentDirectory,
                                                in: .userDomainMask)[0].appendingPathComponent("wallet")
        
            let fileManager = FileManager.default
            var isDir: ObjCBool = false
            let exists = fileManager.fileExists(atPath: path.path,isDirectory: &isDir)
            if(!exists && !isDir.boolValue){
                return
            }
            
            let content = fileManager.contents(atPath: path.path)
            keyStore = EthereumKeystoreV3(content!)
            hasKeyStore = true
    }

    
    func login(completion: @escaping(Bool) -> Void) {
        showProgressView = true
        // Create keystore if no keystore was found
        if !hasKeyStore {
            KeyStoreServices.shared.createKeyStore(credentials: credentials) { [unowned self] (result:Result<Bool, Authentication.AuthenticationError>) in
                showProgressView = false
                switch result {
                case .success:
                    completion(true)
                case .failure(let authError):
                    print(authError)
                    credentials = Credentials()
                    error = authError
                    completion(false)
                }
            }
        }else{
            // Checksum with existing keystore
            KeyStoreServices.shared.checkKeyStore(keyStore: keyStore!, credentials: credentials) {  [unowned self] (result:Result<Bool, Authentication.AuthenticationError>) in
                showProgressView = false
                switch result {
                case .success:
                    completion(true)
                case .failure(let authError):
                    print(authError)
                    credentials = Credentials()
                    error = authError
                    completion(false)
                }
            }
        }
    }

}
    


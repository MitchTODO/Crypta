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
    @Published var error:KeyStoreServices.KeyStoreServicesError?
    
    @Published var hasKeyStore = KeyStoreServices.shared.hasKeyStore
    
    
    func login(completion: @escaping(Bool) -> Void) {
        showProgressView = true
        // Create keystore if no keystore was found
        if !hasKeyStore {
            KeyStoreServices.shared.createKeyStore(credentials: credentials) { [unowned self] (result:Result<Bool, KeyStoreServices.KeyStoreServicesError>) in
                showProgressView = false
                switch result {
                case .success:
                    completion(true)
                case .failure(let authError):
                    credentials = Credentials()
                    error = authError
                    completion(false)
                }
            }
        }else{
            // Checksum with existing keystore
            let keyStore = KeyStoreServices.shared.getKeyManager()
            KeyStoreServices.shared.verifyKeyStore(keyStore: keyStore, credentials: credentials) {  [unowned self] (result:Result<Bool, KeyStoreServices.KeyStoreServicesError>) in
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
    


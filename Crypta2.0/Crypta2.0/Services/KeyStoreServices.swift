//
//  WalletServices.swift
//  Crypta
//
//  Created by Mitch on 7/13/22.
//

import Foundation
import web3swift

class KeyStoreServices {
    static let shared = KeyStoreServices()
    
    // MARK: creaetKeyStore
    // Creates new keystore and writes to file
    func createKeyStore(credentials:Credentials,completion:@escaping(Result<Bool,Authentication.AuthenticationError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
                do{
                    // Create new keystore with new password
                    let keystore = try! EthereumKeystoreV3(password: credentials.password)!
                    let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
                    // save keystore to file
                    let path = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask)[0].appendingPathComponent("wallet")
                    
                    try keyData.write(to: path)
                    completion(.success(true))
                } catch {
                    completion(.failure(.failedToSaveKeyStore))
                }
        }
    }
    
    // MARK: checkKeyStore
    // Checksum to check keystore ownership
    func checkKeyStore(keyStore:EthereumKeystoreV3,credentials:Credentials,completion:@escaping(Result<Bool,Authentication.AuthenticationError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            do{
                // This is a sketchy checksum dont use for production
                try keyStore.regenerate(oldPassword: credentials.password, newPassword:credentials.password)
                completion(.success(true))
            }catch{
                completion(.failure(.invalidCredentials))
            }
        }
        
        
    }
    
    // MARK: getKeyStore
    // reads keystore from file 
    func getKeyStore() -> EthereumKeystoreV3? {
            let path = FileManager.default.urls(for: .documentDirectory,
                                                in: .userDomainMask)[0].appendingPathComponent("wallet")
        
            let fileManager = FileManager.default
            var isDir: ObjCBool = false
            let exists = fileManager.fileExists(atPath: path.path,isDirectory: &isDir)
            if(!exists && !isDir.boolValue){
                print("File dosnt exist for path \(path.path)")
                return nil
            }
            
            let content = fileManager.contents(atPath: path.path)
            let keystore = EthereumKeystoreV3(content!)
            
            return keystore
        
    }
}

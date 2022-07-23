//
//  WalletServices.swift
//  Crypta
//
//  Created by Mitch on 7/13/22.
//

import Foundation
import web3swift
import Security // Could use apple security framework for password checksum

class KeyStoreServices {
    static let shared = KeyStoreServices()
    
    public var keystoreManager:EthereumKeystoreV3?
    public var hasKeyStore = false
    
    enum KeyStoreServicesError:Error,LocalizedError,Identifiable {
        case invalidCredentials
        case failedToGetKeyStore
        case failedToSaveKeyStore

        
        var id:String {
            self.localizedDescription
        }
        
        var errorDescription: String? {
            switch self {
            case.invalidCredentials:
                return NSLocalizedString("Your password in incorrect. Please try again", comment: "")
            case.failedToGetKeyStore:
                return NSLocalizedString("Failed to find key store.", comment: "")
            case.failedToSaveKeyStore:
                return NSLocalizedString("Failed to save key store.", comment: "")

            }
        }
    }
    
    init(){
            // check for keystore
            guard let keystore = readKeyStore() else { return  }
            keystoreManager = keystore
            hasKeyStore = true
        
    }
    
    func getKeyManager() -> EthereumKeystoreV3 {
        return keystoreManager!
    }
    
    // MARK: creaetKeyStore
    /// Creates new keystore and writes to file
    /// - Returns: completion: Bool on success , KeyStoreServicesError on failure
    func createKeyStore(credentials:Credentials,completion:@escaping(Result<Bool,KeyStoreServicesError>) -> Void) {
        do {
            // Create new keystore with new password
            let keystore = try! EthereumKeystoreV3(password: credentials.password)!
            let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
            keystoreManager = keystore
            // save keystore to file
            let path = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)[0].appendingPathComponent("wallet")
          
            try keyData.write(to: path)
            completion(.success(true))
        } catch {
            
            completion(.failure(.failedToSaveKeyStore))
        }
    }
    
    // MARK: checkKeyStore
    /// Verifys keystore ownership
    /// - Returns: completion: Bool on success , KeyStoreServicesError on failure
    func verifyKeyStore(keyStore:EthereumKeystoreV3,credentials:Credentials,completion:@escaping(Result<Bool,KeyStoreServicesError>) -> Void) {
            do{
                // This is a sketchy checksum dont use for production
                try keyStore.regenerate(oldPassword: credentials.password, newPassword:credentials.password)
                completion(.success(true))
            }catch{
                //let keyError = KeyStoreServicesError.failedToVerifyKeyStore
                completion(.failure(KeyStoreServicesError.invalidCredentials))
            }
        }
        
    
    // MARK: readKeyStore
    /// This function returns reads keystore from file path.
    ///
    /// - Returns: reads keystore from file `EthereumKeystoreV3`.
    func readKeyStore() -> EthereumKeystoreV3? {
 
        let path = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)[0].appendingPathComponent("wallet")
 
    
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        let exists = fileManager.fileExists(atPath: path.path,isDirectory: &isDir)
        if(!exists && !isDir.boolValue){
            return nil
        }
        
        let content = fileManager.contents(atPath: path.path)
        let keystore = EthereumKeystoreV3(content!)
        return keystore
        
    }
}

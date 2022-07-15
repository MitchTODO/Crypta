//
//  Authentication.swift
//  Crypta
//
//  Created by Mitch on 7/5/22.
//

import SwiftUI

class Authentication:ObservableObject {

    @Published var isValidated = false
    
    enum AuthenticationError:Error,LocalizedError,Identifiable {
        case invalidCredentials
        case failedToSaveKeyStore
        
        var id:String {
            self.localizedDescription
        }
        
        var errorDescription: String? {
            switch self {
            case.invalidCredentials:
                return NSLocalizedString("Your password in incorrect. Please try again", comment: "")
            case.failedToSaveKeyStore:
                return NSLocalizedString("Faild to create and save wallet to device.", comment: "")
            }
        }
    }
    
    func updateValidation(success:Bool) {
        withAnimation {
            isValidated = success
        }
    }
}


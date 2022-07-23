//
//  Authentication.swift
//  Crypta
//
//  Created by Mitch on 7/5/22.
//

import SwiftUI

class Authentication:ObservableObject {
    @Published var isValidated = false
    
    func updateValidation(success:Bool) {
        withAnimation {
            isValidated = success
        }
    }
}


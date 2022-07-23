
//
//  CryptaApp.swift
//  Crypta
//
//  Created by Mitch on 7/5/22.
//

import SwiftUI

@main
struct CryptaApp2_0App: App {
    @StateObject var authentication = Authentication()

    var body: some Scene {
        WindowGroup {
            if authentication.isValidated {
                ContentView().environmentObject(authentication)
            }else {
                LoginView().environmentObject(authentication)
            }
        }
    }
}

//
//  StreetpassApp.swift
//  Streetpass
//
//  Created by Frank Yang on 11/2/24.
//

import SwiftUI

@main
struct StreetpassApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    
    var body: some Scene {
        WindowGroup {
            loginPage()
        }
    }
}

//
//  mainPage.swift
//  Streetpass
//
//  Created by Jodi Yu on 11/2/24.
//

import SwiftUI

struct mainPage: View {
    @State private var isLoggedOut = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("rainbow1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .padding(.top, 50)
                
                // Profile Link
                NavigationLink(destination: profilePage()) {
                    Text("Edit Profile")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                // Generate Matches Button
                NavigationLink(destination: matchesPage()) {
                    Text("Generate Matches")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                // Missed Connections Button
                NavigationLink(destination: missedConnectionsPage()) {
                    Text("Missed Connections")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                // Logout Button
                Button(action: logout) {
                    Text("Logout")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .navigationBarTitle("Main Page", displayMode: .inline)
            .padding()
        }
        .fullScreenCover(isPresented: $isLoggedOut) {
            loginPage() // Show login page when logged out
        }
    }
    
    // Logout function
    func logout() {
        // Implement logout functionality here
        // For example, clear user data, reset login state, etc.
        print("User logged out")
        isLoggedOut = true
    }
}

struct mainPage_Previews: PreviewProvider {
    static var previews: some View {
        mainPage()
    }
}

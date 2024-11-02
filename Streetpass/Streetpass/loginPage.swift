//
//  loginPage.swift
//  Streetpass
//
//  Created by Jodi Yu on 11/2/24.
//

import SwiftUI

struct loginPage: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                Image("templogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150) // Set the frame size as needed
                    .padding(.bottom, 40)

                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)

                Button(action: {
                    // Handle login action
                    print("Login button tapped")
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5.0)
                }
                .padding(.bottom, 20)
                
                // Error Message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal, 40)
                }
                
                NavigationLink(destination: signupPage()) {
                    Text("New user? Sign up")
                }
                .padding(.bottom, 20)
            }
            .padding()
        }
    }
}


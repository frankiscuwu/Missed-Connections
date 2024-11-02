import SwiftUI

struct AccountCreationView: View {
    // State variables to store user input
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Create an Account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)

            // Username Field
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 40)

            // Email Field
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .padding(.horizontal, 40)

            // Password Field with Show/Hide Toggle
            HStack {
                if showPassword {
                    TextField("Password", text: $password)
                } else {
                    SecureField("Password", text: $password)
                }
                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal, 40)

            // Create Account Button
            Button(action: createAccount) {
                Text("Create Account")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 20)

            Spacer()
        }
    }

    // Action for Create Account button
    func createAccount() {
        // Account creation logic here
        print("Creating account for \(username)")
    }
}

struct AccountCreationView_Previews: PreviewProvider {
    static var previews: some View {
        AccountCreationView()
    }
}

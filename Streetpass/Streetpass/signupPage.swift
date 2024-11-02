import SwiftUI

struct signupPage: View {
    @State private var username = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showSuccessMessage = false  // State for showing success message
    @State private var navigateToLogin = false  // State for navigation
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Create an Account")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 50)

                // Username Field
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
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
                
                // Success message
                if showSuccessMessage {
                    Text("Account created successfully!")
                        .foregroundColor(.green)
                        .padding(.top, 20)
                }
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                loginPage()
            }
        }
    }

    // Action for Create Account button
    func createAccount() {
        let newUser = ["username": username, "password": password]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: newUser, options: []) else {
            print("Error: Unable to encode user data")
            return
        }
        
        let url = URL(string: "http://10.239.101.11:5000/signup/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data,
                  let responseObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let message = responseObject["message"] as? String,
                  message == "User created successfully!" else {
                print("Error: Invalid response from server")
                return
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                .foregroundColor(.red)
                .padding(.horizontal, 40)
            }
            
            // Show success message
            DispatchQueue.main.async {
                showSuccessMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showSuccessMessage = false
                    navigateToLogin = true  // Trigger navigation to login page
                }
            }
        }
        
        task.resume()
    }
}

import SwiftUI

struct loginPage: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var loginMessage: String = ""
    @State private var navigateToStupid = false  // State variable for navigation

    var body: some View {
        NavigationStack {
            VStack {
                Image("templogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.top, 50)

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

                Button(action: loginUser) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5.0)
                }
                .padding(.bottom, 20)

                NavigationLink("New user? Sign up", destination: signupPage())
                    .padding(.bottom, 20)
                
                if !loginMessage.isEmpty {
                    Text(loginMessage)
                        .foregroundColor(loginMessage == "Login successful!" ? .green : .red)
                        .padding()
                }
            }
            .padding()
            .navigationDestination(isPresented: $navigateToStupid) {
                stupid()
            }
        }
    }

    func loginUser() {
        let loginData = ["username": username, "password": password]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: loginData, options: []) else {
            print("Error: Unable to encode login data")
            return
        }

        let url = URL(string: "http://10.239.101.11:5000/login/")!
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
                  let message = responseObject["message"] as? String else {
                DispatchQueue.main.async {
                    loginMessage = "Invalid response from server"
                }
                return
            }
            
            DispatchQueue.main.async {
                loginMessage = message == "Login successful!" ? "Login successful!" : "Invalid credentials"
                
                // If login is successful, set a delay before navigating
                if message == "Login successful!" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        navigateToStupid = true
                    }
                }
            }
        }

        task.resume()
    }
}

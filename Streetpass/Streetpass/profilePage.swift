import SwiftUI

struct userProfile: Codable {
    var interest1: String
    var interest2: String
    var interest3: String
    var links: String
    var school: String
    var major: String
    var hometown: String
}

struct profilePage: View {
    @State private var interest1: String = ""
    @State private var interest2: String = ""
    @State private var interest3: String = ""
    @State private var links: String = ""
    @State private var school: String = ""
    @State private var major: String = ""
    @State private var hometown: String = ""
    @State private var shortened: String = ""
    @State private var saveMessage: String? // Optional variable for success message
    @State private var showAlert: Bool = false // State for alert

    let apiEndpoint = "http://10.239.101.11:5000/post_profile/" // JSON backend URL
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Interests")) {
                    TextField("Interest 1", text: $interest1)
                    TextField("Interest 2", text: $interest2)
                    TextField("Interest 3", text: $interest3)
                }
                
                Section(header: Text("Instagram username")) {
                    TextField("e.g., frank._yang", text: $shortened)
                        .onChange(of: shortened) { newValue in
                            links = "https://www.instagram.com/\(newValue)/"
                        }
                }
                
                Section(header: Text("Education")) {
                    TextField("School", text: $school)
                    TextField("Major", text: $major)
                }
                
                Section(header: Text("Personal Info")) {
                    TextField("Hometown", text: $hometown)
                }
                
                Section {
                    Button(action: saveProfile) {
                        Text("Save Profile")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
                
                if let message = saveMessage {
                    Text(message).foregroundColor(.green).padding()
                }
            }
            .navigationTitle("Edit Profile")
            .onAppear(perform: loadProfile)
            .alert("Profile Saved", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your profile has been successfully saved.")
            }
        }
    }
    
    func saveProfile() {
        let profile = userProfile(
            interest1: interest1,
            interest2: interest2,
            interest3: interest3,
            links: links,
            school: school,
            major: major,
            hometown: hometown
        )
        
        guard let url = URL(string: apiEndpoint) else {
            print("Invalid URL.")
            return
        }
        
        do {
            let jsonData = try JSONEncoder().encode(profile)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Failed to save profile: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.saveMessage = "Profile successfully saved."
                        self.showAlert = true // Show alert on successful save
                    }
                } else {
                    print("Failed to save profile: Server error.")
                }
            }.resume()
            
        } catch {
            print("Failed to encode profile: \(error.localizedDescription)")
        }
    }
    
    func loadProfile() {
        guard let url = URL(string: apiEndpoint) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to load profile: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received.")
                return
            }
            
            do {
                let profile = try JSONDecoder().decode(userProfile.self, from: data)
                
                DispatchQueue.main.async {
                    self.interest1 = profile.interest1
                    self.interest2 = profile.interest2
                    self.interest3 = profile.interest3
                    self.links = profile.links
                    self.school = profile.school
                    self.major = profile.major
                    self.hometown = profile.hometown
                    print("Profile loaded from server.")
                }
                
            } catch {
                print("Failed to decode profile: \(error.localizedDescription)")
            }
        }.resume()
    }
}

#Preview {
    profilePage()
}

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
    
    @State private var interestError: String?
    @State private var linksError: String?
    @State private var schoolError: String?
    @State private var majorError: String?
    @State private var hometownError: String?
    
    let apiEndpoint = "http://10.239.101.11:5000/post_profile/" // URL
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Interests")) {
                    TextField("Interest 1", text: $interest1)
                    TextField("Interest 2", text: $interest2)
                    TextField("Interest 3", text: $interest3)
                    if let error = interestError {
                        Text(error).foregroundColor(.red)
                    }
                }
                
                Section(header: Text("Links")) {
                    TextField("Links (e.g., Instagram, LinkedIn, GitHub)", text: $links)
                    if let error = linksError {
                        Text(error).foregroundColor(.red)
                    }
                }
                
                Section(header: Text("Education")) {
                    TextField("School", text: $school)
                    TextField("Major", text: $major)
                    if let error = schoolError {
                        Text(error).foregroundColor(.red)
                    }
                    if let error = majorError {
                        Text(error).foregroundColor(.red)
                    }
                }
                
                Section(header: Text("Personal Info")) {
                    TextField("Hometown", text: $hometown)
                    if let error = hometownError {
                        Text(error).foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: saveProfile) {
                        Text("Save Profile")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isValidProfile())
                }
            }
            .navigationTitle("Edit Profile")
            .onAppear(perform: loadProfile)
        }
    }
    
    func validateInputs() {
        interestError = interest1.isEmpty || interest2.isEmpty || interest3.isEmpty ? "Please provide all interests." : nil
        linksError = !isValidURL(links) ? "Please provide a valid URL." : nil
        schoolError = school.isEmpty ? "Please provide your school name." : nil
        majorError = major.isEmpty ? "Please provide your major." : nil
        hometownError = hometown.isEmpty ? "Please provide your hometown." : nil
    }
    
    func isValidProfile() -> Bool {
        validateInputs()
        return interestError == nil &&
               linksError == nil &&
               schoolError == nil &&
               majorError == nil &&
               hometownError == nil
    }
    
    // Save profile data to JSON API
    func saveProfile() {
        guard isValidProfile() else { return }
        
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
            print("Invalid URL")
            return
        }
        
        do {
            let jsonData = try JSONEncoder().encode(profile)
            var request = URLRequest(url: url)
            request.httpMethod = "POST" // or "PUT" depending on your API
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Failed to save profile: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("Profile successfully saved.")
                } else {
                    print("Failed to save profile: Server error.")
                }
            }.resume()
            
        } catch {
            print("Failed to encode profile: \(error.localizedDescription)")
        }
    }
    
    // Load profile data from JSON API
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
    
    func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        profilePage()
    }
}

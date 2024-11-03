import SwiftUI

// Define the oneUserProfile struct
struct oneUserProfile: Codable, Identifiable {
    let id = UUID()  // Unique id created
    var username: String
    var interest1: String
    var interest2: String
    var interest3: String
    var links: String
    var school: String
    var major: String
    var hometown: String
}

// Define a struct to decode the friends array
struct FriendsResponse: Codable {
    let friends: [oneUserProfile]
}

struct stalkerAddedPage: View {
    @State private var profiles: [oneUserProfile] = []
    let apiEndpoint = "http://10.239.101.11:5000/get_friends/" // Uncomment this when ready to use the API
    
    var body: some View {
        NavigationView {
            List(profiles) { profile in
                VStack(alignment: .leading) {
                    Text("\(profile.username)")
                        .font(.title)
                    Text("School: \(profile.school)")
                        .font(.subheadline)
                    Text("Major: \(profile.major)")
                        .font(.subheadline)
                    Text("Hometown: \(profile.hometown)")
                        .font(.subheadline)
                    Text("Interests: \(profile.interest1), \(profile.interest2), \(profile.interest3)")
                        .font(.subheadline)
                    if let link = URL(string: profile.links) {
                        Link("View Instagram Profile", destination: link) // Open social profile link
                    }
                }
                .padding()
            }
            .navigationTitle("User Profiles")
            .onAppear(perform: loadProfiles)
        }
    }
    
    func loadProfiles() {
        guard let url = URL(string: apiEndpoint) else {
            print("Invalid URL")
            return
         }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to load profiles: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received.")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(FriendsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.profiles = decodedResponse.friends // Update the profiles state variable
                }
            } catch {
                print("Failed to decode profiles: \(error.localizedDescription)")
            }
        }.resume()
    }
}

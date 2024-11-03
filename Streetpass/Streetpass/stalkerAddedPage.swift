//
//  matchesPage.swift
//  Streetpass
//
//  Created by Jodi Yu on 11/2/24.
//
import SwiftUI

// Define the stalkerAddedPage struct
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

struct stalkerAddedPage: View {
    @State private var profiles: [oneUserProfile] = []
    //let apiEndpoint = "http://10.239.101.11:5000/get_friends/" // api endpoint
    
    var body: some View {
        NavigationView {
            List(profiles) { profile in
                VStack(alignment: .leading) {
                    Text("Username: \(profile.username)").font(.headline)
                    Text("School: \(profile.school)").font(.subheadline)
                    Text("Major: \(profile.major)").font(.subheadline)
                    Text("Hometown: \(profile.hometown)").font(.subheadline)
                    Text("Interests: \(profile.interest1), \(profile.interest2), \(profile.interest3)")
                    if let link = URL(string: profile.links) {
                        Link("View Social Profile", destination: link) // hopefully instagram link
                    }
                }
                .padding()
            }
            .navigationTitle("User Profiles")
            .onAppear(perform: loadProfiles)
        }
    }
    
    func loadProfiles() {
        guard let url = /*URL*/Bundle.main.url(/*string:*/ forResource: "fakeProfiles", withExtension: "json"/*apiEndpoint*/) else {
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
                let decodedProfiles = try JSONDecoder().decode([oneUserProfile].self, from: data)
                DispatchQueue.main.async {
                    self.profiles = decodedProfiles
                }
            } catch {
                print("Failed to decode profiles: \(error.localizedDescription)")
            }
        }.resume()
    }
}

// Preview setup for SwiftUI
struct ProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        stalkerAddedPage()
    }
}


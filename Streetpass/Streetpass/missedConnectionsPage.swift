//
//  missedConnectionsPage.swift
//  Streetpass
//
//  Created by Frank Yang on 11/2/24.
//
import SwiftUI
import MapKit
import Foundation

struct MissedConnectionsPage: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 28.5384, longitude: -81.3789), // Default coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.001)
    )
    
    @State private var messages: [String] = [    ]
    @State private var missedConnectionLocations: [(latitude: Double, longitude: Double)] = []
    @State private var errorMessage: String?
    @State private var currentIndex: Int = 0 // Keep track of the current message index
    @State private var username: [String] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Map(coordinateRegion: $region)
                .frame(width: 350, height: 300)
                .cornerRadius(10)
                .padding()
            
            GeometryReader { geometry in
                TabView(selection: $currentIndex) {
                    if messages.isEmpty {
                        Text("Loading missed connections...")
                            .font(.title)
                            .frame(width: geometry.size.width - 40, height: 200)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    } else {
                        ForEach(messages.indices, id: \.self) { index in
                            Text(messages[index])
                                .padding()
                                .frame(width: geometry.size.width - 40, height: 200)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                                .font(.system(size: 16))
                                .tag(index) // Tag each message with its index
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 220)
                .onChange(of: currentIndex) { newIndex in
                    updateMapRegion(for: newIndex) // Update the map region with the new index
                    // Update the username based on the current index
                    if newIndex < username.count {
                        let currentPerson = username[newIndex]
                        print("Current person for friend request: \(currentPerson)")
                    }
                }
            }
            .padding(.horizontal, 20)
            
            HStack(spacing: 20) {
                Button(action: {
                    print("Delete button tapped")
                }) {
                    Text("Delete")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    // Check if the current index is valid
                    if currentIndex < username.count {
                        // Get the current person's username based on the current index
                        let currentPerson = username[currentIndex]
                        print("Sending friend request to: \(currentPerson)") // Debug statement
                        sendFriendRequest(for: currentPerson)
                    } else {
                        print("Error: Current index \(currentIndex) is out of bounds for usernames array with count \(username.count).") // Debug statement
                    }
                }) {
                    Text("Friend Request")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            Spacer()
        }
        .navigationTitle("Missed Connections")
        .onAppear { fetchMessages() }
    }

    func updateMapRegion(for index: Int) {
        guard index < missedConnectionLocations.count else { return } // Ensure the index is valid
        
        let selectedLocation = missedConnectionLocations[index]
        region.center = CLLocationCoordinate2D(latitude: selectedLocation.latitude, longitude: selectedLocation.longitude)
    }
    
    func unpackAIcall(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "http://10.239.101.11:5000/get_users/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoDataError", code: -1, userInfo: nil)))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(json))
                } else {
                    completion(.failure(NSError(domain: "InvalidJSONError", code: -1, userInfo: nil)))
                }
            } catch let parseError {
                completion(.failure(parseError))
            }
        }
        
        task.resume()
    }
    
    func fetchMissedConnectionMessages(completion: @escaping (Result<[String], Error>) -> Void) {
        unpackAIcall { result in
            switch result {
            case .success(let json):
                guard let recommendations = json["recommendations"] as? [[String: Any]] else {
                    completion(.failure(NSError(domain: "InvalidJSONError", code: -1, userInfo: nil)))
                    return
                }
                
                var messages: [String] = []
                var locations: [(Double, Double)] = [] // Store the locations

                for recommendation in recommendations {
                    guard
                        let person = recommendation["person"] as? String,
                        let major = recommendation["major"] as? String,
                        let school = recommendation["school"] as? String,
                        let latitude = recommendation["latitude"] as? Double,
                        let longitude = recommendation["longitude"] as? Double,
                        let reason = recommendation["reason"] as? String
                    else {
                        continue
                    }

                    let message = "You missed a connection with \(person), a(n) \(major) major from \(school) .\n\(reason)"
                    messages.append(message)
                    locations.append((latitude, longitude)) // Add to locations array
                    username.append(person)
                }
                
                // Update the missed connection locations state variable
                self.missedConnectionLocations = locations
                
                completion(.success(messages))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchMessages() {
        fetchMissedConnectionMessages { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newMessages):
                    self.messages.append(contentsOf: newMessages)
                    if let firstIndex = self.missedConnectionLocations.indices.first {
                        updateMapRegion(for: firstIndex) // Update the map region to the first message's location
                    }
                case .failure(let error):
                    self.errorMessage = "Failed to load message: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func sendFriendRequest(for person: String) {
        // URL for sending the friend request
        guard let url = URL(string: "http://10.239.101.11:5000/post_friends/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create JSON object with the person's name
        let json: [String: Any] = ["username": person]
        
        // Convert the JSON object to Data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error creating JSON data: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending friend request: \(error.localizedDescription)")
                return
            }
            
            // Handle response if needed
            if let data = data {
                // Optionally parse the response here if needed
                print("Friend request response: \(String(data: data, encoding: .utf8) ?? "")")
            }
        }
        
        task.resume()
    }
}

#Preview {
    MissedConnectionsPage()
}

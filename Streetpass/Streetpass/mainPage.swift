//
//  mainPage.swift
//  Streetpass
//
//  Created by Jodi Yu on 11/2/24.
//

import SwiftUI
import CoreLocation

struct mainPage: View {
    @State private var isLoggedOut = false
    @StateObject private var locationManager = LocationManager()
    @State private var statusMessage: String = "Press the button to send your location"
    
    @State private var showAlert: Bool = false
    @State private var responseCode: Int? = nil
    @State private var responseData: String = ""
    @State private var timer: Timer?
    
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
        .onAppear() {
            startLocationTimer()
        }
    }
    
    // Logout function
    func logout() {
        // Implement logout functionality here
        // For example, clear user data, reset login state, etc.
        print("User logged out")
        isLoggedOut = true
    }
    
    
    func sendLocation() {
        if let location = locationManager.currentLocation {
            let locationData = locationToJSON(location: location)
            sendLocationData(locationData: locationData)
            statusMessage = "Sending location..."
        } else {
            statusMessage = "Location not available. Make sure permissions are enabled."
        }
    }

    func locationToJSON(location: CLLocation) -> [String: Any] {
        return [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude
        ]
    }

    func sendLocationData(locationData: [String: Any]) {
        guard let url = URL(string: "http://10.239.101.11:5000/post_location/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: locationData, options: [])
        } catch {
            print("Error serializing JSON:", error)
            statusMessage = "Error sending data."
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error sending data:", error)
                    statusMessage = "Failed to send location."
                    responseCode = nil
                    responseData = ""
                } else if let httpResponse = response as? HTTPURLResponse {
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Successfully sent location data! Response code: \(httpResponse.statusCode)")
                        statusMessage = "Location sent successfully!"
                        responseCode = httpResponse.statusCode
                        responseData = responseString
                    } else {
                        responseCode = httpResponse.statusCode
                        responseData = "No data received."
                    }
                }
                showAlert = true
            }
        }

        task.resume()
    }

    func startLocationTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 20 * 60, repeats: true) { _ in
            self.sendLocation()
        }
        
        statusMessage = "Started sending location every 20m."
    }
}

import SwiftUI
import CoreLocation

struct stupid: View {
    @StateObject private var locationManager = LocationManager()
    @State private var statusMessage: String = "Press the button to send your location"
    
    // State variables for showing the alert and response data
    @State private var showAlert: Bool = false
    @State private var responseCode: Int? = nil // Store the response code
    @State private var responseData: String = "" // Store the response data
    @State private var timer: Timer? // Timer for automatic location sending
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text(statusMessage)
                .padding()
                .multilineTextAlignment(.center)
            
            Button(action: {
                sendLocation()
            }) {
                Text("Send Location")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            Button(action: {
                startLocationTimer()
            }) {
                Text("Start Sending Location Every 3 seconds")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Response Code"),
                message: Text("Response code: \(responseCode ?? 0)\nResponse data: \(responseData)"),
                dismissButton: .default(Text("OK"))
            )
        }
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
                    // Handle response data
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Successfully sent location data! Response code: \(httpResponse.statusCode)")
                        statusMessage = "Location sent successfully!"
                        responseCode = httpResponse.statusCode // Store the response code
                        responseData = responseString // Store the response data as a string
                    } else {
                        responseCode = httpResponse.statusCode
                        responseData = "No data received."
                    }
                }
                showAlert = true // Show the alert
            }
        }

        task.resume()
    }

    func startLocationTimer() {
        // Invalidate the previous timer if it exists
        timer?.invalidate()
        
        // Set up a new timer to send location every 3 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            self.sendLocation() // Send the current location
        }
        
        statusMessage = "Started sending location every 20 minutes."
    }
}

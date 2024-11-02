import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var name: String = ""
    @State private var statusMessage: String = "Press the button to send your location"

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter your name:")
                .font(.headline)
            
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
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
        }
        .padding()
    }
    
    func sendLocation() {
        if let location = locationManager.currentLocation {
            let locationData = locationToJSON(location: location)
            sendLocationData(locationData: locationData)
            statusMessage = "Location sent successfully!"
        } else {
            statusMessage = "Location not available. Make sure permissions are enabled."
        }
    }

    func locationToJSON(location: CLLocation) -> [String: Any] {
        return [
            "name": name,
            "lat": location.coordinate.latitude,
            "long": location.coordinate.longitude
        ]
    }

    func sendLocationData(locationData: [String: Any]) {
        guard let url = URL(string: "http://10.239.101.11:5000/locate") else { return }

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
                    return
                }
                print("Successfully sent location data!")
                statusMessage = "Location sent successfully!"
            }
        }

        task.resume()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

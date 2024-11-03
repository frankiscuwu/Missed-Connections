import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringSignificantLocationChanges() // Start monitoring significant location changes
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        
        // Send location data whenever an update occurs
        sendLocationData(location: location) // Call your method to send the location data
    }

    private func sendLocationData(location: CLLocation) {
        let locationData = locationToJSON(location: location)
        
        guard let url = URL(string: "http://10.239.101.11:5000/post_location/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: locationData, options: [])
        } catch {
            print("Error serializing JSON:", error)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending data:", error)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("Successfully sent location data! Response code: \(httpResponse.statusCode)")
            }
        }

        task.resume()
    }

    func locationToJSON(location: CLLocation) -> [String: Any] {
        return [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude
        ]
    }
}

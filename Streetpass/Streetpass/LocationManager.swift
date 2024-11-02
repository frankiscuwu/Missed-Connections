import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    @Published var currentLocation: CLLocation?

    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        
        // Request location permissions
        locationManager.requestAlwaysAuthorization() // or requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Set desired accuracy
        locationManager.startUpdatingLocation() // Start receiving location updates
    }

    func startUpdatingLocation() {
        // Check if location services are enabled
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            print("Location services are not enabled")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        print("Updated location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        // Handle your location update logic here (e.g., sending it to a server)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        currentLocation = nil // Set currentLocation to nil on failure
    }
}

import UIKit
import CoreLocation

class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize the location manager
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        // Request location permissions
        locationManager?.requestAlwaysAuthorization() // or requestWhenInUseAuthorization()

        // Start monitoring significant location changes
        locationManager?.startMonitoringSignificantLocationChanges()
        
        // Ensure that the location manager can update location in the background
        locationManager?.allowsBackgroundLocationUpdates = true
        
        return true
    }

    // CLLocationManagerDelegate method to handle authorization status changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // Start location updates if permission is granted
            manager.startUpdatingLocation()
        case .denied, .restricted:
            // Handle the case where the user has denied or restricted location services
            print("Location services are denied or restricted")
        default:
            break
        }
    }

    // CLLocationManagerDelegate method to handle location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("Updated location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        // Handle your location update logic here (e.g., send to your server)
    }

    // CLLocationManagerDelegate method to handle errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
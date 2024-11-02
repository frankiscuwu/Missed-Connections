//
//  LocationManager.swift
//  Streetpass
//
//  Created by Frank Yang on 11/2/24.
//

import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    // Use @Published so that changes in this property are observed by SwiftUI
    @Published var currentLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // Request permission to access location
        locationManager.startUpdatingLocation()         // Start getting location updates
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                self.currentLocation = location // This triggers SwiftUI to update any view observing this value
            }
            locationManager.stopUpdatingLocation()      // Stop updating to save battery
        }
    }
}


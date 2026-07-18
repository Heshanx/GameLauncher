//
//  LocationService.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import Foundation
import CoreLocation

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var errorMessage: String?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    func requestPermission() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
            manager.stopUpdatingLocation() 
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Capture the error
        DispatchQueue.main.async {
            self.errorMessage = "Failed to get location: \(error.localizedDescription)"
        }
    }
    
    // For manual testing/re-triggering
    func checkStatus() -> String {
        switch manager.authorizationStatus {
        case .denied: return "Permission Denied"
        case .authorizedWhenInUse: return "Permission Granted"
        default: return "Permission Unknown"
        }
    }
}

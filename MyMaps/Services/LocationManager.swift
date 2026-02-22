//
//  LocationManager.swift
//  MyMaps
//
//  Created by Saimur Rashid on 1/31/26.
//


import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var userLocation: CLLocation?
    @Published var region = MKCoordinateRegion()
    
    private var hasSetInitialRegion = false

    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10
    }

    func requestLocationPermission() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("DEBUG: Location access denied. Guide user to settings.")
        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
        
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        self.userLocation = location
        
        if !hasSetInitialRegion {
            updateRegion(to: location)
            hasSetInitialRegion = true
        }
    }
    
    private func updateRegion(to location: CLLocation) {
        self.region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    func recenter() {
        if let location = userLocation {
            updateRegion(to: location)
        }
    }
}

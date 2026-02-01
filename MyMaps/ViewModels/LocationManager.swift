//
//  LocationManager.swift
//  MyMaps
//
//  Created by Saimur Rashid on 1/31/26.
//


import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus?

    override init() {
        super.init()
        manager.delegate = self
        // Capture the initial status immediately
        self.authorizationStatus = manager.authorizationStatus
    }

    func requestLocationPermission() {
        // If we already have permission, don't ask again
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            // If already authorized or denied, manually trigger the status change
            self.authorizationStatus = manager.authorizationStatus
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
    }
}

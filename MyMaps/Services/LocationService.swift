//
//  LocationService.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/1/26.
//

import MapKit
import CoreLocation

class LocationService {
    
    func getPlaceDetails(coords: CLLocation) async -> Place? {
        let request = MKLocalPointsOfInterestRequest(center: coords.coordinate, radius: 100)
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            
            if let mapItem = response.mapItems.first {
                return Place(
                    name: mapItem.name ?? "Unknown Spot",
                    address: mapItem.placemark.title ?? "",
                    latitude: coords.coordinate.latitude,
                    longitude: coords.coordinate.longitude
                )
            }
        } catch {
            print("DEBUG: POI Search unavailable - \(error.localizedDescription)")
        }
        
        return await reverseGeocode(coords)
    }
    
    private func reverseGeocode(_ coords: CLLocation) async -> Place? {
        let geocoder = CLGeocoder()
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(coords)
            
            if let p = placemarks.first {
                return Place(
                    name: p.name ?? "Dropped Pin",
                    address: formatAddress(from: p),
                    latitude: coords.coordinate.latitude,
                    longitude: coords.coordinate.longitude
                )
            }
        } catch {
            print("DEBUG: Geocoding error - \(error.localizedDescription)")
        }
        return nil
    }
    
    private func formatAddress(from placemark: CLPlacemark) -> String {
        let number = placemark.subThoroughfare ?? ""
        let street = placemark.thoroughfare ?? ""
        let city = placemark.locality ?? ""
        
        let streetPart = "\(number) \(street)".trimmingCharacters(in: .whitespaces)
        
        if streetPart.isEmpty {
            return city
        } else {
            return "\(streetPart), \(city)".trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}

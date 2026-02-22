//
//  Place.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/1/26.
//

import Foundation
import CoreLocation

struct Place: Codable, Equatable {
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

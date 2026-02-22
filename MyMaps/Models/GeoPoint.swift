//
//  GeoPoint.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/15/26.
//

import CoreLocation
import FirebaseFirestore

extension GeoPoint {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

//
//  Post.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/1/26.
//

import Foundation
import FirebaseFirestore
import CoreLocation

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    let authorId: String
    let authorName: String
    var authorProfileImageUrl: String?
    let imageUrl: String
    let location: GeoPoint
    let placeName: String
    let address: String
    let vibe: VibeCategory
    let caption: String
    let createdAt: Date
    let rating: Int
    var likes: [String] = []

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }

    func isLiked(by userId: String) -> Bool {
        likes.contains(userId)
    }
}

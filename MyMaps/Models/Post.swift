//
//  Post.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/1/26.
//

import Foundation
import FirebaseFirestore

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    let authorId: String
    let authorName: String
    let imageUrl: String
    let location: GeoPoint
    let placeName: String
    let address: String
    let vibe: VibeType
    let caption: String
    let createdAt: Date
    let rating: Int 
}

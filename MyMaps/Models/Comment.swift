//
//  Comment.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/15/26.
//

import Foundation
import FirebaseFirestore

struct Comment: Identifiable, Codable {
    @DocumentID var id: String?
    let postOwnerId: String
    let authorId: String
    let authorUsername: String
    let profileImageUrl: String?
    let commentText: String
    let timestamp: Date
}

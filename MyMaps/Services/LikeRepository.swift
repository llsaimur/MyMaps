//
//  LikeRepository.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/31/26.
//

import FirebaseFirestore

struct LikeRepository {
    
    private let db = Firestore.firestore()

    func toggleLike(postId: String, currentUserId: String, currentlyLiked: Bool) async throws {
        let ref = db.collection("posts").document(postId)
        if currentlyLiked {
            try await ref.updateData(["likes": FieldValue.arrayRemove([currentUserId])])
        } else {
            try await ref.updateData(["likes": FieldValue.arrayUnion([currentUserId])])
        }
    }
}

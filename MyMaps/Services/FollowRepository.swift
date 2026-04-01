//
//  FollowRepository.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/31/26.
//

import FirebaseFirestore

struct FollowRepository {
    	
    private let db = Firestore.firestore()

    func follow(currentUserId: String, targetUserId: String) async throws {
        let batch = db.batch()
        let currentRef = db.collection("users").document(currentUserId)
        let targetRef  = db.collection("users").document(targetUserId)

        batch.updateData([
            "followingIDs":   FieldValue.arrayUnion([targetUserId]),
            "followingCount": FieldValue.increment(Int64(1))
        ], forDocument: currentRef)

        batch.updateData([
            "followerIDs":   FieldValue.arrayUnion([currentUserId]),
            "followerCount": FieldValue.increment(Int64(1))
        ], forDocument: targetRef)

        try await batch.commit()
    }

    func unfollow(currentUserId: String, targetUserId: String) async throws {
        let batch = db.batch()
        let currentRef = db.collection("users").document(currentUserId)
        let targetRef  = db.collection("users").document(targetUserId)

        batch.updateData([
            "followingIDs":   FieldValue.arrayRemove([targetUserId]),
            "followingCount": FieldValue.increment(Int64(-1))
        ], forDocument: currentRef)

        batch.updateData([
            "followerIDs":   FieldValue.arrayRemove([currentUserId]),
            "followerCount": FieldValue.increment(Int64(-1))
        ], forDocument: targetRef)

        try await batch.commit()
    }

    func observeFollowingIDs(currentUserId: String, onUpdate: @escaping ([String]) -> Void) -> ListenerRegistration {
        db.collection("users").document(currentUserId).addSnapshotListener { snapshot, _ in
            let ids = snapshot?.data()?["followingIDs"] as? [String] ?? []
            onUpdate(ids)
        }
    }

    func observeFollowState(
        currentUserId: String,
        targetUserId: String,
        onUpdate: @escaping (Bool) -> Void
    ) -> ListenerRegistration {
        db.collection("users").document(targetUserId).addSnapshotListener { snapshot, _ in
            let followerIDs = snapshot?.data()?["followerIDs"] as? [String] ?? []
            onUpdate(followerIDs.contains(currentUserId))
        }
    }
}

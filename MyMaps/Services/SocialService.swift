//
//  SocialService.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/22/26.
//


import Firebase
import FirebaseFirestore
import FirebaseAuth

struct SocialService {
    private static let db = Firestore.firestore()
    
    static func follow(uid: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let batch = db.batch()
        
        let followingRef = db.collection("users").document(currentUid).collection("user-following").document(uid)
        batch.setData([:], forDocument: followingRef)
        
        let followersRef = db.collection("users").document(uid).collection("user-followers").document(currentUid)
        batch.setData([:], forDocument: followersRef)
        
        let currentUserRef = db.collection("users").document(currentUid)
        batch.updateData(["followingCount": FieldValue.increment(Int64(1))], forDocument: currentUserRef)
        
        let targetUserRef = db.collection("users").document(uid)
        batch.updateData(["followerCount": FieldValue.increment(Int64(1))], forDocument: targetUserRef)
        
        try await batch.commit()
    }
    
    static func unfollow(uid: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let batch = db.batch()
        
        batch.deleteDocument(db.collection("users").document(currentUid).collection("user-following").document(uid))
        batch.deleteDocument(db.collection("users").document(uid).collection("user-followers").document(currentUid))
        
        batch.updateData(["followingCount": FieldValue.increment(Int64(-1))], forDocument: db.collection("users").document(currentUid))
        batch.updateData(["followerCount": FieldValue.increment(Int64(-1))], forDocument: db.collection("users").document(uid))
        
        try await batch.commit()
    }
    
    static func checkIfFollowing(uid: String) async throws -> Bool {
        guard let currentUid = Auth.auth().currentUser?.uid else { return false }
        let snapshot = try await db.collection("users").document(currentUid).collection("user-following").document(uid).getDocument()
        return snapshot.exists
    }
    
    static func searchUsers(withUsername query: String) async throws -> [User] {
        let snapshot = try await db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: query.lowercased())
            .whereField("username", isLessThanOrEqualTo: query.lowercased() + "\u{f8ff}")
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: User.self) }
    }
}

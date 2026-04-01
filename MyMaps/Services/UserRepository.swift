//
//  UserRepository.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/31/26.
//

import FirebaseFirestore
import FirebaseStorage

class UserRepository {
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()



    func createUserDocument(uid: String, email: String, username: String, fullname: String) async throws {
        let data: [String: Any] = [
            "uid": uid,
            "email": email,
            "username": username.lowercased(),
            "fullname": fullname,
            "followingCount": 0,
            "followerCount": 0,
            "followingIDs": [String](),
            "followerIDs": [String]()
        ]
        try await db.collection("users").document(uid).setData(data)
    }

    func updateProfile(uid: String, fullname: String, username: String) async throws {
        try await db.collection("users").document(uid).updateData([
            "fullname": fullname,
            "username": username.lowercased()
        ])
    }

    func updateProfileImageUrl(uid: String, urlString: String) async throws {
        try await db.collection("users").document(uid).updateData([
            "profileImageUrl": urlString
        ])
    }

    func deleteUserDocument(uid: String) async throws {
        try await db.collection("users").document(uid).delete()
    }


    func fetchUser(uid: String) async throws -> User {
        let snapshot = try await db.collection("users").document(uid).getDocument()
        return try snapshot.data(as: User.self)
    }


    func fetchUsername(uid: String) async throws -> String {
        let snapshot = try await db.collection("users").document(uid).getDocument()
        return snapshot.data()?["username"] as? String ?? "Explorer"
    }


    func fetchAllUsers(limit: Int = 100) async throws -> [User] {
        let snapshot = try await db.collection("users")
            .order(by: "username")
            .limit(to: limit)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: User.self) }
    }


    func fetchUsers(byIds ids: [String]) async throws -> [User] {
        guard !ids.isEmpty else { return [] }
        var results: [User] = []

        let chunks = stride(from: 0, to: ids.count, by: 10).map {
            Array(ids[$0 ..< min($0 + 10, ids.count)])
        }
        for chunk in chunks {
            let snapshot = try await db.collection("users")
                .whereField("uid", in: chunk)
                .getDocuments()
            results += snapshot.documents.compactMap { try? $0.data(as: User.self) }
        }
        return results
    }


    func observeUser(uid: String, onUpdate: @escaping (User) -> Void) -> ListenerRegistration {
        db.collection("users").document(uid).addSnapshotListener { snapshot, error in
            if let error = error {
                print("DEBUG UserRepository: observeUser error — \(error.localizedDescription)")
                return
            }
            guard let snapshot, snapshot.exists else { return }
            do {
                let user = try snapshot.data(as: User.self)
                onUpdate(user)
            } catch {
                print("DEBUG UserRepository: decode error — \(error)")
            }
        }
    }


    func observeUserSearch(query: String, onUpdate: @escaping ([User]) -> Void) -> ListenerRegistration {
        db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: query.lowercased())
            .whereField("username", isLessThanOrEqualTo: query.lowercased() + "\u{f8ff}")
            .addSnapshotListener { snapshot, _ in
                let users = snapshot?.documents.compactMap { try? $0.data(as: User.self) } ?? []
                onUpdate(users)
            }
    }


    func uploadProfileImage(uid: String, imageData: Data) async throws -> String {
        let ref = storage.child("profile_images/\(uid)/photo.jpg")
        _ = try await ref.putDataAsync(imageData)
        return try await ref.downloadURL().absoluteString
    }
}

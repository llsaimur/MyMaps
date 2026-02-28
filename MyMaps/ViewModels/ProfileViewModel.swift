//
//  ProfileViewModel.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/22/26.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var posts = [Post]()
    @Published var isFollowing = false
    
    private let db = Firestore.firestore()
    private var userListener: ListenerRegistration?
    private var postsListener: ListenerRegistration?
    private var followListener: ListenerRegistration?
    
    init(user: User) {
        self.user = user
        startListening()
    }
    
    deinit {
        userListener?.remove()
        postsListener?.remove()
        followListener?.remove()
    }
    
    func startListening() {
        observeUserProfile()
        observeUserPosts()
        checkIfUserIsFollowed()
    }
    
    
    private func observeUserProfile() {
        userListener = db.collection("users").document(user.uid)
            .addSnapshotListener { snapshot, _ in
                guard let updatedUser = try? snapshot?.data(as: User.self) else { return }
                self.user = updatedUser
            }
    }
    
    private func observeUserPosts() {
        postsListener = db.collection("posts")
            .whereField("authorId", isEqualTo: user.uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { querySnapshot, _ in
                guard let documents = querySnapshot?.documents else { return }
                self.posts = documents.compactMap { try? $0.data(as: Post.self) }
            }
    }
    
    private func checkIfUserIsFollowed() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard !user.isCurrentUser else { return }
        
        followListener = db.collection("users").document(currentUid)
            .collection("user-following").document(user.uid)
            .addSnapshotListener { snapshot, _ in
                self.isFollowing = snapshot?.exists ?? false
            }
    }
    
    
    func follow() {
        Task {
            do {
                try await SocialService.follow(uid: user.uid)
                HapticManager.trigger(.light)
            } catch {
                print("DEBUG: Error following user - \(error.localizedDescription)")
            }
        }
    }

    func unfollow() {
        Task {
            do {
                try await SocialService.unfollow(uid: user.uid)
                HapticManager.trigger(.light)
            } catch {
                print("DEBUG: Error unfollowing user - \(error.localizedDescription)")
            }
        }
    }
}

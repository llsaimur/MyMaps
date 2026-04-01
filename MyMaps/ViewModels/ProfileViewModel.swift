//
//  ProfileViewModel.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/22/26.
//

import SwiftUI
import FirebaseFirestore

@MainActor
class ProfileViewModel: ObservableObject {

    @Published var user: User
    @Published var posts: [Post] = []
    @Published var isFollowing = false

    var isCurrentUser: Bool { user.uid == currentUserId }

    private let userRepository   = UserRepository()
    private let postRepository   = PostRepository()
    private let followRepository = FollowRepository()

    private let currentUserId: String
    private var userListener:   ListenerRegistration?
    private var postsListener:  ListenerRegistration?
    private var followListener: ListenerRegistration?

    init(user: User, currentUserId: String? = nil) {
        self.user = user
        self.currentUserId = currentUserId ?? AuthViewModel.shared.userSession?.uid ?? ""
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
        observeFollowState()
    }

    private func observeUserProfile() {
        userListener = userRepository.observeUser(uid: user.uid) { [weak self] updatedUser in
            self?.user = updatedUser
        }
    }

    private func observeUserPosts() {
        postsListener = postRepository.listenToPosts(byAuthorId: user.uid) { [weak self] result in
            switch result {
            case .success(let fetched): self?.posts = fetched
            case .failure(let error):
                print("DEBUG ProfileViewModel: observeUserPosts — \(error.localizedDescription)")
            }
        }
    }

    private func observeFollowState() {
        guard !isCurrentUser, !currentUserId.isEmpty else { return }
        followListener = followRepository.observeFollowState(
            currentUserId: currentUserId,
            targetUserId: user.uid
        ) { [weak self] following in
            self?.isFollowing = following
        }
    }

    func follow() {
        guard !currentUserId.isEmpty else { return }
        Task {
            do {
                try await followRepository.follow(currentUserId: currentUserId, targetUserId: user.uid)
                HapticManager.trigger(.light)
            } catch {
                print("DEBUG ProfileViewModel: follow — \(error.localizedDescription)")
            }
        }
    }

    func unfollow() {
        guard !currentUserId.isEmpty else { return }
        Task {
            do {
                try await followRepository.unfollow(currentUserId: currentUserId, targetUserId: user.uid)
                HapticManager.trigger(.light)
            } catch {
                print("DEBUG ProfileViewModel: unfollow — \(error.localizedDescription)")
            }
        }
    }
}

//
//  ExploreViewModel.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/31/26.
//

import Foundation
import FirebaseFirestore

@MainActor
class ExploreViewModel: ObservableObject {

    @Published var allUsers: [User] = []
    @Published var searchResults: [User] = []
    @Published var followingIDs: Set<String> = []
    @Published var isLoading = false

    private let userRepository   = UserRepository()
    private let followRepository = FollowRepository()
    private var searchListener: ListenerRegistration?

    var displayedUsers: [User] { searchText.isEmpty ? allUsers : searchResults }

    private(set) var searchText = ""

    func loadUsers(currentUserId: String) {
        guard allUsers.isEmpty else { return }
        isLoading = true
        Task {
            do {
                let fetched = try await userRepository.fetchAllUsers()
                allUsers = fetched.filter { $0.uid != currentUserId }
                followingIDs = Set(allUsers.compactMap { followingIDs.contains($0.uid) ? $0.uid : nil })
            } catch {
                print("DEBUG ExploreViewModel: loadUsers — \(error.localizedDescription)")
            }
            isLoading = false
        }
    }

    func syncFollowingIDs(from currentUser: User) {
        followingIDs = Set(currentUser.followingIDs)
    }

    func search(query: String, currentUserId: String) {
        searchText = query
        guard !query.isEmpty else {
            searchResults = []
            searchListener?.remove()
            searchListener = nil
            return
        }
        searchListener?.remove()
        searchListener = userRepository.observeUserSearch(query: query) { [weak self] users in
            guard let self else { return }
            self.searchResults = users.filter { $0.uid != currentUserId }
            for user in users {
                if !self.followingIDs.contains(user.uid) {}
            }
        }
    }

    func clearSearch() {
        searchText = ""
        searchResults = []
        searchListener?.remove()
        searchListener = nil
    }

    func toggleFollow(targetUserId: String, currentUserId: String) {
        let currentlyFollowing = followingIDs.contains(targetUserId)
        if currentlyFollowing {
            followingIDs.remove(targetUserId)
        } else {
            followingIDs.insert(targetUserId)
        }
        HapticManager.trigger(.light)
        Task {
            do {
                if currentlyFollowing {
                    try await followRepository.unfollow(currentUserId: currentUserId, targetUserId: targetUserId)
                } else {
                    try await followRepository.follow(currentUserId: currentUserId, targetUserId: targetUserId)
                }
            } catch {
                if currentlyFollowing {
                    followingIDs.insert(targetUserId)
                } else {
                    followingIDs.remove(targetUserId)
                }
                print("DEBUG ExploreViewModel: toggleFollow failed — \(error.localizedDescription)")
            }
        }
    }

    deinit {
        searchListener?.remove()
    }
}

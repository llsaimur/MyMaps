//
//  DiscoveryViewModel.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/31/26.
//

import SwiftUI
import FirebaseFirestore

@MainActor
class DiscoveryViewModel: ObservableObject {


    @Published var discoveryPosts: [Post] = []
    @Published var selectedCategory: VibeCategory? = nil
    @Published var isLoading = false

    private let postRepository = PostRepository()
    private var postListener: ListenerRegistration?

    private var currentUserId: String = ""
    private var followingIDs: [String] = []

    init() { }

    deinit {
        postListener?.remove()
    }

    func configure(currentUserId: String, followingIDs: [String]) {
        let changed = self.currentUserId != currentUserId || self.followingIDs != followingIDs
        self.currentUserId = currentUserId
        self.followingIDs  = followingIDs
        if changed { observeDiscoveryPosts() }
    }


    func updateCategory(_ category: VibeCategory?) {
        selectedCategory = category
        observeDiscoveryPosts()
    }


    func observeDiscoveryPosts() {
        postListener?.remove()
        isLoading = true

        if let category = selectedCategory {
            postListener = postRepository.listenToPosts(vibe: category, limit: 50) { [weak self] result in
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let posts): self.discoveryPosts = posts
                case .failure(let error):
                    print("DEBUG DiscoveryViewModel: \(error.localizedDescription)")
                    self.discoveryPosts = []
                }
            }
        } else {
            guard !followingIDs.isEmpty else {
                postListener = nil
                discoveryPosts = []
                isLoading = false
                return
            }
            postListener = postRepository.listenToPosts(byAuthorIds: followingIDs) { [weak self] result in
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let posts): self.discoveryPosts = posts
                case .failure(let error):
                    print("DEBUG DiscoveryViewModel: \(error.localizedDescription)")
                    self.discoveryPosts = []
                }
            }
        }
    }
}

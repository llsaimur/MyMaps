//
//  MapViewModel.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/1/26.
//

import SwiftUI
import MapKit
import Combine
import FirebaseFirestore

struct SelectedLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

@MainActor
class MapViewModel: ObservableObject {

    @Published var posts: [Post] = []
    @Published var selectedLocation: SelectedLocation?
    @Published var selectedCategory: VibeCategory? = nil
    @Published var searchText = ""
    @Published var searchResults: [MKMapItem] = []

    private let repository      = PostRepository()
    private let followRepository = FollowRepository()
    private let currentUserId: String

    private var cancellables     = Set<AnyCancellable>()
    private var postListener:   ListenerRegistration?
    private var followListener: ListenerRegistration?

    init(currentUserId: String) {
        self.currentUserId = currentUserId
        setupSearchDebounce()
        listenForFriendPosts()
    }

    deinit {
        postListener?.remove()
        followListener?.remove()
    }

    func updateFilter(to category: VibeCategory?) {
        selectedCategory = category
        HapticManager.trigger(.light)
        if let category {
            listenForGlobalCategory(category)
        } else {
            listenForFriendPosts()
        }
    }

    private func listenForGlobalCategory(_ category: VibeCategory) {
        stopPostListener()
        followListener?.remove()
        followListener = nil

        postListener = repository.listenToPosts(vibe: category) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let fetched):
                withAnimation(.spring()) { self.posts = fetched }
            case .failure(let error):
                print("DEBUG MapViewModel: listenForGlobalCategory — \(error.localizedDescription)")
            }
        }
    }

    func listenForFriendPosts() {
        guard !currentUserId.isEmpty else { return }
        stopPostListener()
        followListener?.remove()

        followListener = followRepository.observeFollowingIDs(currentUserId: currentUserId) { [weak self] ids in
            guard let self else { return }
            guard !ids.isEmpty else {
                self.posts = []
                return
            }
            self.listenForPosts(byIds: ids)
        }
    }

    private func listenForPosts(byIds ids: [String]) {
        stopPostListener()
        let queryIds = Array(ids.prefix(10))
        postListener = repository.listenToPosts(byAuthorIds: queryIds) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let fetched):
                withAnimation(.spring()) { self.posts = fetched }
            case .failure(let error):
                print("DEBUG MapViewModel: listenForPosts — \(error.localizedDescription)")
            }
        }
    }

    func stopPostListener() {
        postListener?.remove()
        postListener = nil
    }

    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self else { return }
                if text.isEmpty {
                    self.searchResults = []
                } else {
                    self.performSearch(query: text)
                }
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        MKLocalSearch(request: request).start { [weak self] response, error in
            if let error {
                print("DEBUG MapViewModel: search — \(error.localizedDescription)")
                return
            }
            Task { @MainActor in
                self?.searchResults = response?.mapItems ?? []
            }
        }
    }
}

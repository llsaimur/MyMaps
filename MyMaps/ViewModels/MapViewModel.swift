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
    
    @Published var searchText = ""
    @Published var searchResults: [MKMapItem] = []
    
    private let repository = PostRepository()
    private var cancellables = Set<AnyCancellable>()
    private var postListener: ListenerRegistration?
    
    init() {
        setupSearchDebounce()
        listenForPosts()
    }
    
    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self = self else { return }
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
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("DEBUG: Search error - \(error.localizedDescription)")
                return
            }
            
            Task { @MainActor in
                self.searchResults = response?.mapItems ?? []
            }
        }
    }
    
    func listenForPosts() {
        stopListening()
        
        postListener = repository.listenToPosts { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let fetchedPosts):
                    self?.posts = fetchedPosts
                case .failure(let error):
                    print("DEBUG: Error fetching posts - \(error.localizedDescription)")
                }
            }
        }
    }
    
    func stopListening() {
        postListener?.remove()
        postListener = nil
    }
    
    deinit {
        postListener?.remove()
    }
}

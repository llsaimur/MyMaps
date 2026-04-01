//
//  CreatePostViewModel.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/1/26.
//

import SwiftUI
import MapKit
import PhotosUI
import FirebaseFirestore

@MainActor
class CreatePostViewModel: ObservableObject {

    @Published var uiState: FormState = .idle
    @Published var isPostEnabled = false

    @Published var selectedImage: UIImage? { didSet { validateInput() } }
    @Published var detectedPlace: Place?   { didSet { validateInput() } }
    @Published var caption = ""            { didSet { validateInput() } }
    @Published var rating  = 0             { didSet { validateInput() } }

    @Published var selectedVibe: VibeCategory = .CHILL
    @Published var showSearch = false
    @Published var searchResults: [MKMapItem] = []
    @Published var searchQuery = ""

    var initialCoordinate: CLLocationCoordinate2D?

    private let locationService  = LocationService()
    private let postRepository   = PostRepository()
    private let userRepository   = UserRepository()
    private var compressedImageData: Data?

    func fetchLocationDetails(for coordinate: CLLocationCoordinate2D) {
        uiState = .loading
        Task {
            let place = await locationService.getPlaceDetails(
                coords: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            )
            detectedPlace = place
            uiState = .idle
            if place == nil { showSearch = true }
            validateInput()
        }
    }

    func selectPlace(_ item: MKMapItem) {
        let coords = item.placemark.coordinate
        detectedPlace = Place(
            name: item.name ?? "Selected Location",
            address: item.placemark.title ?? "",
            latitude: coords.latitude,
            longitude: coords.longitude
        )
        showSearch = false
        searchQuery = ""
        searchResults = []
        validateInput()
    }

    func performSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        if let coord = initialCoordinate {
            request.region = MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
        MKLocalSearch(request: request).start { [weak self] response, _ in
            self?.searchResults = response?.mapItems ?? []
        }
    }

    func handlePhotoProcessing(image: UIImage) {
        selectedImage = image
        compressImage(image)
    }

    private func compressImage(_ image: UIImage) {
        Task.detached(priority: .userInitiated) {
            if let data = image.jpegData(compressionQuality: 0.7) {
                await MainActor.run {
                    self.compressedImageData = data
                    self.validateInput()
                }
            }
        }
    }


    func validateInput() {
        let hasImage   = selectedImage != nil && compressedImageData != nil
        let hasPlace   = detectedPlace != nil
        let hasContent = !caption.trimmingCharacters(in: .whitespaces).isEmpty && rating > 0
        isPostEnabled  = hasImage && hasPlace && hasContent
    }


    func submitPost(currentUserId: String) async {
        guard !currentUserId.isEmpty,
              let imageData = compressedImageData,
              let place = detectedPlace else { return }

        uiState = .uploading
        do {
            let username = try await userRepository.fetchUsername(uid: currentUserId)

            let profileImageUrl = AuthViewModel.shared.currentUser?.profileImageUrl
            let newPost = Post(
                authorId:  currentUserId,
                authorName: username,
                authorProfileImageUrl: profileImageUrl,
                imageUrl:  "",
                location:  GeoPoint(latitude: place.latitude, longitude: place.longitude),
                placeName: place.name,
                address:   place.address,
                vibe:      selectedVibe,
                caption:   caption,
                createdAt: Date(),
                rating:    rating
            )
            try await postRepository.createPost(post: newPost, imageData: imageData)
            uiState = .success
        } catch {
            print("DEBUG CreatePostViewModel: submitPost — \(error.localizedDescription)")
            uiState = .error
        }
    }
}


enum FormState {
    case idle, loading, uploading, success, error
}

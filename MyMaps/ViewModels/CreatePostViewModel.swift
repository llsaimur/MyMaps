//
//  CreatePostViewModel.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/1/26.
//


import SwiftUI
import MapKit
import PhotosUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class CreatePostViewModel: ObservableObject {
    @Published var uiState: FormState = .idle
    @Published var isPostEnabled: Bool = false
    
    @Published var selectedImage: UIImage? { didSet { validateInput() } }
    @Published var detectedPlace: Place? { didSet { validateInput() } }
    @Published var caption: String = "" { didSet { validateInput() } }
    @Published var rating: Int = 0 { didSet { validateInput() } }
    
    @Published var selectedVibe: VibeType = .CHILL
    @Published var showSearch = false
    @Published var searchResults: [MKMapItem] = []
    @Published var searchQuery: String = ""

    private var compressedImageData: Data?
    var initialCoordinate: CLLocationCoordinate2D?
    
    private let locationService = LocationService()
    private let repository = PostRepository()
    private let db = Firestore.firestore()

    
    func fetchLocationDetails(for coordinate: CLLocationCoordinate2D) {
        self.uiState = .loading
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        Task {
            let place = await locationService.getPlaceDetails(coords: location)
            
            await MainActor.run {
                self.detectedPlace = place
                self.uiState = .idle
                
                if place == nil {
                    self.showSearch = true
                }
                self.validateInput()
            }
        }
    }

    func selectPlace(_ item: MKMapItem) {
        let coords = item.placemark.coordinate
        self.detectedPlace = Place(
            name: item.name ?? "Selected Location",
            address: item.placemark.title ?? "",
            latitude: coords.latitude,
            longitude: coords.longitude
        )
        self.showSearch = false
        self.searchQuery = ""
        self.searchResults = []
        self.validateInput()
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
        
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            self.searchResults = response?.mapItems ?? []
        }
    }

    
    func handlePhotoProcessing(image: UIImage) {
        self.selectedImage = image
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
        let hasImage = selectedImage != nil && compressedImageData != nil
        let hasPlace = detectedPlace != nil
        let hasContent = !caption.trimmingCharacters(in: .whitespaces).isEmpty && rating > 0
        
        self.isPostEnabled = hasImage && hasPlace && hasContent
    }
    
    func submitPost() async {
        guard let currentUID = Auth.auth().currentUser?.uid,
              let imageData = compressedImageData,
              let place = detectedPlace else { return }
        
        self.uiState = .uploading
        
        do {
            let userDoc = try await db.collection("users").document(currentUID).getDocument()
            let username = userDoc.data()?["username"] as? String ?? "Explorer"
            
            let newPost = Post(
                authorId: currentUID,
                authorName: username,
                imageUrl: "",
                location: GeoPoint(latitude: place.latitude, longitude: place.longitude),
                placeName: place.name,
                address: place.address,
                vibe: selectedVibe,
                caption: caption,
                createdAt: Date(),
                rating: rating
            )
            
            try await repository.createPost(post: newPost, imageData: imageData)
            self.uiState = .success
        } catch {
            print("CreatePost Error: \(error.localizedDescription)")
            self.uiState = .error
        }
    }
}

enum FormState {
    case idle
    case loading
    case uploading
    case success
    case error
}

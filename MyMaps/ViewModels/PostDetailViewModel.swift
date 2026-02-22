//
//  PostDetailViewModel.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/16/26.
//


import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseAuth

@MainActor
class PostDetailViewModel: ObservableObject {
    @Published var post: Post
    @Published var authorName: String = "Loading..."
    @Published var showDeleteConfirmation = false
    @Published var isEditing = false
    
    private let db = Firestore.firestore()
    private let repository = PostRepository()
    
    init(post: Post) {
        self.post = post
    }
    
    var isOwner: Bool {
        guard let currentUid = Auth.auth().currentUser?.uid else { return false }
        return currentUid == post.authorId
    }
    
    func fetchAuthorName() {
        db.collection("users").document(post.authorId).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let data = snapshot?.data(), let name = data["username"] as? String {
                    self?.authorName = name
                } else {
                    self?.authorName = "Unknown Explorer"
                }
            }
        }
    }
    
    func deletePost(onSuccess: @escaping () -> Void) {
        Task {
            do {
                try await repository.deletePost(postId: post.id)
                onSuccess()
            } catch {
                print("DEBUG: Failed to delete post - \(error.localizedDescription)")
            }
        }
    }
    
    func openInMaps() {
        let coordinate = post.location.coordinate
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = post.placeName
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

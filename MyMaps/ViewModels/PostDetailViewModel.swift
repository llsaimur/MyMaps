//
//  PostDetailViewModel.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/16/26.
//

import SwiftUI
import MapKit

@MainActor
class PostDetailViewModel: ObservableObject {

    @Published var post: Post
    @Published var authorName = "Loading..."
    @Published var showDeleteConfirmation = false
    @Published var isEditing = false

    var isOwner: Bool { post.authorId == currentUserId }

    private let postRepository = PostRepository()
    private let userRepository = UserRepository()
    private let currentUserId: String

    init(post: Post, currentUserId: String? = nil) {
        self.post = post
        self.currentUserId = currentUserId ?? AuthViewModel.shared.userSession?.uid ?? ""
    }

    func fetchAuthorName() {
        Task {
            do {
                authorName = try await userRepository.fetchUsername(uid: post.authorId)
            } catch {
                authorName = "Unknown Explorer"
                print("DEBUG PostDetailViewModel: fetchAuthorName — \(error.localizedDescription)")
            }
        }
    }

    func deletePost(onSuccess: @escaping () -> Void) {
        Task {
            do {
                try await postRepository.deletePost(postId: post.id)
                onSuccess()
            } catch {
                print("DEBUG PostDetailViewModel: deletePost — \(error.localizedDescription)")
            }
        }
    }

    func openInMaps() {
        let placemark = MKPlacemark(coordinate: post.coordinate)
        let mapItem   = MKMapItem(placemark: placemark)
        mapItem.name  = post.placeName
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

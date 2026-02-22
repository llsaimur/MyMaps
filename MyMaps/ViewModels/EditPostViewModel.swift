//
//  EditPostViewModel.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/16/26.
//


import SwiftUI

@MainActor
class EditPostViewModel: ObservableObject {
    @Published var rating: Int
    @Published var selectedVibe: VibeType
    @Published var caption: String
    @Published var isSaving = false
    
    let post: Post
    private let repository = PostRepository()
    
    init(post: Post) {
        self.post = post
        self.rating = post.rating ?? 0
        self.selectedVibe = post.vibe
        self.caption = post.caption
    }
    
    var isSaveDisabled: Bool {
        caption.trimmingCharacters(in: .whitespaces).isEmpty || rating == 0 || isSaving
    }
    
    func save(onSuccess: @escaping (Post) -> Void) async {
        isSaving = true
        
        let updatedPost = Post(
            id: post.id,
            authorId: post.authorId,
            authorName: post.authorName,
            imageUrl: post.imageUrl,
            location: post.location,
            placeName: post.placeName,
            address: post.address,
            vibe: selectedVibe,
            caption: caption,
            createdAt: post.createdAt,
            rating: rating
        )
        
        do {
            try await repository.updatePost(updatedPost)
            HapticManager.trigger(.success)
            onSuccess(updatedPost)
        } catch {
            print("Error updating post: \(error.localizedDescription)")
            isSaving = false
        }
    }
}

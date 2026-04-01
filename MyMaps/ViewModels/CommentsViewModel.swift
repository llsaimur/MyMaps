//
//  CommentsViewModel.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/31/26.
//

import Foundation
import FirebaseFirestore

@MainActor
class CommentsViewModel: ObservableObject {


    @Published var comments: [Comment] = []
    @Published var commentText = ""

    private let commentRepository = CommentRepository()
    private var listener: ListenerRegistration?
    private let postId: String

    init(postId: String) {
        self.postId = postId
    }

    deinit {
        listener?.remove()
    }


    func startListening() {
        listener?.remove()
        listener = commentRepository.observeComments(postId: postId) { [weak self] fetched in
            Task { @MainActor in
                self?.comments = fetched
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }


    func submitComment(postOwnerId: String, currentUserId: String, username: String, profileImageUrl: String?) async {
        let text = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        commentText = ""

        let comment = Comment(
            postOwnerId: postOwnerId,
            authorId: currentUserId,
            authorUsername: username,
            profileImageUrl: profileImageUrl,
            commentText: text,
            timestamp: Date()
        )
        do {
            try await commentRepository.uploadComment(comment, postId: postId)
            HapticManager.trigger(.success)
        } catch {
            print("DEBUG CommentsViewModel: submitComment — \(error.localizedDescription)")
        }
    }
}

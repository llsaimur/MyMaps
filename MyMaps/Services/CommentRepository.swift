//
//  CommentRepository.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/31/26.
//

import FirebaseFirestore

struct CommentRepository {
    private let db = Firestore.firestore()

    func uploadComment(_ comment: Comment, postId: String) async throws {
        guard let encodedComment = try? Firestore.Encoder().encode(comment) else { return }
        try await db.collection("posts")
            .document(postId)
            .collection("comments")
            .addDocument(data: encodedComment)
    }

    func observeComments(postId: String, onUpdate: @escaping ([Comment]) -> Void) -> ListenerRegistration {
        db.collection("posts")
            .document(postId)
            .collection("comments")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("DEBUG CommentRepository: \(error.localizedDescription)")
                    return
                }
                let comments = snapshot?.documents.compactMap { try? $0.data(as: Comment.self) } ?? []
                onUpdate(comments)
            }
    }
}

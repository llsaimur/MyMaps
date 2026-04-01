//
//  PostRepository.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/1/26.
//


import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class PostRepository {
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    func createPost(post: Post, imageData: Data) async throws {
        let imageId = UUID().uuidString
        let imageRef = storage.child("users/\(post.authorId)/posts/\(imageId).jpg")
        
        _ = try await imageRef.putDataAsync(imageData)
        let downloadUrl = try await imageRef.downloadURL().absoluteString
        
        var finalPost = post

        let postWithUrl = Post(
            id: post.id,
            authorId: post.authorId,
            authorName: post.authorName,
            imageUrl: downloadUrl,
            location: post.location,
            placeName: post.placeName,
            address: post.address,
            vibe: post.vibe,
            caption: post.caption,
            createdAt: post.createdAt,
            rating: post.rating,
            likes: []
        )
        
        try db.collection("posts").addDocument(from: postWithUrl)
    }
    
    func listenToPosts(completion: @escaping (Result<[Post], Error>) -> Void) -> ListenerRegistration {
        return db.collection("posts")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                let posts = querySnapshot?.documents.compactMap { try? $0.data(as: Post.self) } ?? []
                completion(.success(posts))
            }
    }
    
    func updatePost(_ post: Post) async throws {
        guard let postId = post.id else { return }
        try db.collection("posts").document(postId).setData(from: post, merge: true)
    }
    
    func deletePost(postId: String?) async throws {
        guard let postId = postId else {
            throw NSError(domain: "PostRepository", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid Post ID"])
        }
        
        try await db.collection("posts").document(postId).delete()
    }
    
    func fetchPosts(forUid uid: String) async throws -> [Post] {
        let snapshot = try await db.collection("posts")
            .whereField("authorId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: Post.self) }
    }


    func listenToPosts(
        vibe: VibeCategory,
        limit: Int = 100,
        completion: @escaping (Result<[Post], Error>) -> Void
    ) -> ListenerRegistration {
        db.collection("posts")
            .whereField("vibe", isEqualTo: vibe.rawValue)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .addSnapshotListener { snapshot, error in
                if let error { completion(.failure(error)); return }
                let posts = snapshot?.documents.compactMap { try? $0.data(as: Post.self) } ?? []
                completion(.success(posts))
            }
    }


    func listenToPosts(
        byAuthorIds ids: [String],
        completion: @escaping (Result<[Post], Error>) -> Void
    ) -> ListenerRegistration {
        db.collection("posts")
            .whereField("authorId", in: ids)
            .addSnapshotListener { snapshot, error in
                if let error { completion(.failure(error)); return }
                let posts = snapshot?.documents.compactMap { try? $0.data(as: Post.self) } ?? []
                completion(.success(posts))
            }
    }


    func listenToPosts(
        byAuthorId uid: String,
        completion: @escaping (Result<[Post], Error>) -> Void
    ) -> ListenerRegistration {
        db.collection("posts")
            .whereField("authorId", isEqualTo: uid)
            .addSnapshotListener { snapshot, error in
                if let error { completion(.failure(error)); return }
                let posts = (snapshot?.documents.compactMap { try? $0.data(as: Post.self) } ?? [])
                    .sorted { $0.createdAt > $1.createdAt }
                completion(.success(posts))
            }
    }
}

//
//  WishlistRepository.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/31/26.
//

import FirebaseFirestore

struct WishlistRepository {
    private let db = Firestore.firestore()

    func fetchWishlist(userId: String) async throws -> [WishlistItem] {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("wishlist")
            .order(by: "dateSaved", descending: true)
            .limit(to: 50)
            .getDocuments()

        return snapshot.documents.compactMap { doc -> WishlistItem? in
            let data = doc.data()
            guard
                let placeName  = data["placeName"]  as? String,
                let address    = data["address"]    as? String,
                let vibeTag    = data["vibeTag"]    as? String,
                let timestamp  = data["dateSaved"]  as? TimeInterval
            else { return nil }

            return WishlistItem(
                id: doc.documentID,
                placeName: placeName,
                address: address,
                vibeTag: vibeTag,
                dateSaved: Date(timeIntervalSince1970: timestamp)
            )
        }
    }
}

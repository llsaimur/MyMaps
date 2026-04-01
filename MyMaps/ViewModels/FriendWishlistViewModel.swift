//
//  FriendWishlistViewModel.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/31/26.
//

import Foundation

@MainActor
class FriendWishlistViewModel: ObservableObject {

    @Published var items: [WishlistItem] = []
    @Published var isLoading = false

    private let wishlistRepository = WishlistRepository()

    func load(for uid: String) {
        isLoading = true
        Task {
            do {
                items = try await wishlistRepository.fetchWishlist(userId: uid)
            } catch {
                print("DEBUG FriendWishlistViewModel: load — \(error.localizedDescription)")
                items = []
            }
            isLoading = false
        }
    }
}

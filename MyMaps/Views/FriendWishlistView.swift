//
//  FriendWishlistView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/28/26.
//

import SwiftUI

struct FriendWishlistView: View {
    let user: User
    @StateObject private var viewModel = FriendWishlistViewModel()

    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
            } else if viewModel.items.isEmpty {
                ContentUnavailableView {
                    Label("Empty Bucket", systemImage: "list.star")
                } description: {
                    Text("\(user.username) hasn't added any places yet.")
                }
                .listRowSeparator(.hidden)
            } else {
                ForEach(viewModel.items) { item in
                    BucketItemRow(
                        placeName: item.placeName,
                        address: item.address,
                        vibeTag: item.vibeTag,
                        dateSaved: item.dateSaved
                    )
                }
            }
        }
        .navigationTitle("\(user.username)'s Bucket")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.load(for: user.uid)
        }
    }
}

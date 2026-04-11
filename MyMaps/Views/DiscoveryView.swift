//
//  DiscoveryView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/31/26.
//

import SwiftUI

struct DiscoveryView: View {
    @StateObject private var viewModel = DiscoveryViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                categoryFilterBar

                if viewModel.isLoading {
                    ProgressView().padding(.top, 40)
                    Spacer()
                } else if viewModel.discoveryPosts.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 25) {
                            ForEach(viewModel.discoveryPosts) { post in
                                FeedRow(post: post)
                            }
                        }
                        .padding(.top, 12)
                    }
                    .refreshable { viewModel.observeDiscoveryPosts() }
                }
            }
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { configureViewModel() }
            .onChange(of: authViewModel.currentUser) { _, _ in configureViewModel() }
        }
    }

    private var categoryFilterBar: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(title: "Friends", isSelected: viewModel.selectedCategory == nil) {
                        viewModel.updateCategory(nil)
                    }
                    ForEach(VibeCategory.allCases, id: \.self) { category in
                        FilterChip(
                            title: category.displayName,
                            isSelected: viewModel.selectedCategory == category
                        ) {
                            viewModel.updateCategory(category)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            Divider()
        }
        .background(Color(.systemBackground))
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 50))
                .foregroundStyle(.blue.gradient)
            Text(
                viewModel.selectedCategory == nil
                    ? "No Vibes from Friends"
                    : "No \(viewModel.selectedCategory?.displayName ?? "") Vibes Yet"
            )
            .font(.headline)
            Text(
                viewModel.selectedCategory == nil
                    ? "Follow people to see their vibes here."
                    : "Be the first to share a vibe in this category!"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            if viewModel.selectedCategory != nil {
                Button { viewModel.updateCategory(nil) } label: {
                    Text("Back to Friends Feed")
                        .font(.subheadline).bold()
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            Spacer()
            Spacer()
        }
    }


    private func configureViewModel() {
        let uid = authViewModel.currentUser?.uid ?? ""
        let following = authViewModel.currentUser?.followingIDs ?? []
        viewModel.configure(currentUserId: uid, followingIDs: following)
    }
}

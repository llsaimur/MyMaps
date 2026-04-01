//
//  ExploreView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/22/26.
//

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ExploreViewModel()
    @State private var searchText = ""

    private var currentUserId: String { authViewModel.currentUser?.uid ?? "" }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.displayedUsers.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Users Yet" : "No Results",
                        systemImage: searchText.isEmpty ? "person.2" : "magnifyingglass",
                        description: Text(
                            searchText.isEmpty
                                ? "Users who join will appear here."
                                : "No users match \"\(searchText)\"."
                        )
                    )
                } else {
                    List(viewModel.displayedUsers, id: \.uid) { user in
                        userRow(for: user)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("People")
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search people..."
            )
            .onAppear {
                viewModel.loadUsers(currentUserId: currentUserId)
                if let user = authViewModel.currentUser {
                    viewModel.syncFollowingIDs(from: user)
                }
            }
            .onDisappear {
                viewModel.clearSearch()
            }
            .onChange(of: authViewModel.currentUser) { _, user in
                if let user {
                    if viewModel.allUsers.isEmpty {
                        viewModel.loadUsers(currentUserId: user.uid)
                    }
                    viewModel.syncFollowingIDs(from: user)
                }
            }
            .onChange(of: searchText) { _, query in
                if query.isEmpty {
                    viewModel.clearSearch()
                } else {
                    viewModel.search(query: query.lowercased(), currentUserId: currentUserId)
                }
            }
        }
    }

    private func userRow(for user: User) -> some View {
        HStack(spacing: 12) {
            NavigationLink(destination: ProfileView(viewModel: ProfileViewModel(user: user))) {
                HStack(spacing: 12) {
                    UserAvatarView(profileImageUrl: user.profileImageUrl, size: 46)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.username)
                            .font(.system(size: 15, weight: .semibold))
                        Text(user.fullname)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer()

            if user.uid != currentUserId {
                followButton(for: user)
            }
        }
    }

    private func followButton(for user: User) -> some View {
        let isFollowing = viewModel.followingIDs.contains(user.uid)
        return Button {
            viewModel.toggleFollow(targetUserId: user.uid, currentUserId: currentUserId)
        } label: {
            Text(isFollowing ? "Following" : "Follow")
                .font(.system(size: 13, weight: .semibold))
                .frame(width: 90, height: 32)
                .foregroundStyle(isFollowing ? Color.primary : Color.white)
                .background(isFollowing ? Color.gray.opacity(0.15) : Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

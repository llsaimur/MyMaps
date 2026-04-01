//
//  UserListView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/31/26.
//

import SwiftUI

struct UserListView: View {
    let mode: UserListMode
    let user: User

    @StateObject private var viewModel = UserListViewModel()

    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
            } else if viewModel.users.isEmpty {
                ContentUnavailableView(
                    mode == .followers ? "No Followers" : "Not Following Anyone",
                    systemImage: "person.2.slash",
                    description: Text("When users connect, they will appear here.")
                )
            } else {
                ForEach(viewModel.users) { listedUser in
                    NavigationLink(destination: ProfileView(viewModel: ProfileViewModel(user: listedUser))) {
                        UserRow(user: listedUser)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(mode == .followers ? "Followers" : "Following")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            let ids = mode == .followers ? user.followerIDs : user.followingIDs
            await viewModel.load(userIds: ids)
        }
    }
}

struct UserRow: View {
    let user: User

    var body: some View {
        HStack(spacing: 12) {
            UserAvatarView(profileImageUrl: user.profileImageUrl, size: 40)
            VStack(alignment: .leading) {
                Text(user.username)
                    .font(.system(size: 14, weight: .semibold))
                Text(user.fullname)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

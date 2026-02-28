//
//  ProfileView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/22/26.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @State private var selectedPost: Post?
    
    private let gridItems: [GridItem] = [
        .init(.flexible(), spacing: 1),
        .init(.flexible(), spacing: 1),
        .init(.flexible(), spacing: 1)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(.gray.opacity(0.3))
                    
                    Text("@\(viewModel.user.username)")
                        .font(.headline)
                    
                    HStack(spacing: 32) {
                        UserStatView(value: viewModel.posts.count, label: "Posts")
                        UserStatView(value: viewModel.user.followerCount, label: "Followers")
                        UserStatView(value: viewModel.user.followingCount, label: "Following")
                    }
                    
                    if !viewModel.user.isCurrentUser {
                        followButton
                    }
                }
                .padding(.top)
                
                Divider()
                
                if viewModel.posts.isEmpty {
                    ContentUnavailableView("No Vibes Yet", systemImage: "photo.on.rectangle", description: Text("Shared vibes will appear here."))
                        .padding(.top, 40)
                } else {
                    LazyVGrid(columns: gridItems, spacing: 1) {
                        ForEach(viewModel.posts) { post in
                            AsyncImage(url: URL(string: post.imageUrl)) { image in
                                image.resizable()
                                    .aspectRatio(1, contentMode: .fill)
                            } placeholder: {
                                Color.gray.opacity(0.1)
                            }
                            .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
                            .clipped()
                            .onTapGesture { selectedPost = post }
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.user.isCurrentUser ? "My Profile" : viewModel.user.username)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedPost) { post in
            PostDetailView(viewModel: PostDetailViewModel(post: post), onUpdate: { _ in })
        }
    }
    
    private var followButton: some View {
        Button {
            if viewModel.isFollowing {
                viewModel.unfollow()
            } else {
                viewModel.follow()
            }
        } label: {
            Text(viewModel.isFollowing ? "Following" : "Follow")
                .font(.subheadline).bold()
                .frame(width: 120, height: 32)
                .foregroundStyle(viewModel.isFollowing ? .black : .white)
                .background(viewModel.isFollowing ? Color.white : Color.blue)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.3), lineWidth: viewModel.isFollowing ? 1 : 0)
                )
        }
        .cornerRadius(6)
    }
}

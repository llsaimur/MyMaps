//
//  ProfileView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/22/26.
//

import SwiftUI
import SDWebImageSwiftUI
import MapKit
import CoreData
import PhotosUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.managedObjectContext) private var viewContext

    @StateObject private var friendWishlistVM = FriendWishlistViewModel()

    @State private var selectedTab: Int = 0
    @State private var showUserList = false
    @State private var listMode: UserListMode = .followers
    @State private var showSettings = false
    @State private var selectedPhoto: PhotosPickerItem?

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BucketItem.dateSaved, ascending: false)],
        animation: .default)
    private var bucketItems: FetchedResults<BucketItem>

    private let gridItems: [GridItem] = [
        .init(.flexible(), spacing: 1),
        .init(.flexible(), spacing: 1),
        .init(.flexible(), spacing: 1)
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    profileHeader
                    tabSelector
                    tabContent
                }
            }
        }
        .navigationTitle(viewModel.isCurrentUser ? "My Profile" : viewModel.user.username)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.isCurrentUser {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .refreshable { viewModel.startListening() }
        .sheet(isPresented: $showSettings) {
            SettingsView().environmentObject(authViewModel)
        }
        .navigationDestination(isPresented: $showUserList) {
            UserListView(mode: listMode, user: viewModel.user)
        }
        .onChange(of: selectedPhoto) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await authViewModel.uploadProfileImage(image)
                }
            }
        }
    }
}

private extension ProfileView {

    @ViewBuilder
    var profileImageView: some View {
        let avatar = UserAvatarView(profileImageUrl: viewModel.user.profileImageUrl, size: 80)
            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))

        if viewModel.isCurrentUser {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                ZStack(alignment: .bottomTrailing) {
                    avatar
                    Image(systemName: "pencil.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                        .background(Color.white.clipShape(Circle()))
                        .offset(x: 4, y: 4)
                }
            }
        } else {
            avatar
        }
    }

    var profileHeader: some View {
        VStack(spacing: 12) {
            profileImageView
            Text("@\(viewModel.user.username)").font(.headline)
            HStack(spacing: 24) {
                UserStatView(value: viewModel.posts.count, label: "Posts")
                Button {
                    listMode = .followers; showUserList = true
                } label: {
                    UserStatView(value: viewModel.user.followerCount, label: "Followers")
                }
                .buttonStyle(.plain)
                Button {
                    listMode = .following; showUserList = true
                } label: {
                    UserStatView(value: viewModel.user.followingCount, label: "Following")
                }
                .buttonStyle(.plain)
            }
            if !viewModel.isCurrentUser { followButton }
        }
        .padding(.top)
    }

    var tabSelector: some View {
        let tabWidth = UIScreen.main.bounds.width / 3

        return VStack(spacing: 0) {
            HStack {
                Spacer()
                Button { selectedTab = 0 } label: {
                    Image(systemName: "square.grid.3x3")
                        .font(.system(size: 20))
                        .foregroundStyle(selectedTab == 0 ? .primary : .secondary)
                }
                Spacer()
                Button { selectedTab = 1 } label: {
                    Image(systemName: "map")
                        .font(.system(size: 20))
                        .foregroundStyle(selectedTab == 1 ? .primary : .secondary)
                }
                Spacer()
                Button { selectedTab = 2 } label: {
                    Image(systemName: "bookmark")
                        .font(.system(size: 20))
                        .foregroundStyle(selectedTab == 2 ? .primary : .secondary)
                }
                Spacer()
            }
            .padding(.vertical, 12)

            ZStack(alignment: .leading) {
                Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: tabWidth, height: 1.5)
                    .offset(x: CGFloat(selectedTab) * tabWidth)
                    .animation(.spring(response: 0.3), value: selectedTab)
            }
        }
    }

    @ViewBuilder
    var tabContent: some View {
        switch selectedTab {
        case 0:
            if viewModel.posts.isEmpty { emptyStateView } else { postGrid }
        case 1:
            ProfileMapView(posts: viewModel.posts)
                .frame(height: 450)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
        default:
            if viewModel.isCurrentUser {
                wishlistSection
            } else {
                friendWishlistSection
            }
        }
    }

    var postGrid: some View {
        LazyVGrid(columns: gridItems, spacing: 1) {
            ForEach(viewModel.posts) { post in
                NavigationLink(
                    destination: PostDetailView(
                        viewModel: PostDetailViewModel(post: post),
                        onUpdate: { _ in }
                    )
                ) {
                    PostGridItem(post: post)
                }
                .buttonStyle(.plain)
            }
        }
    }

    var wishlistSection: some View {
        Group {
            if bucketItems.isEmpty {
                ContentUnavailableView {
                    Label("Bucket is Empty", systemImage: "bookmark")
                } description: {
                    Text("Tap the bookmark on any post to save it here.")
                }
                .padding(.top, 40)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(bucketItems) { item in
                        WishlistItemRow(item: item)
                            .padding(.horizontal)
                        Divider().padding(.leading)
                    }
                }
            }
        }
    }

    var friendWishlistSection: some View {
        Group {
            if friendWishlistVM.isLoading {
                ProgressView().padding(.top, 40)
            } else if friendWishlistVM.items.isEmpty {
                ContentUnavailableView {
                    Label("Empty Bucket", systemImage: "bookmark")
                } description: {
                    Text("\(viewModel.user.username) hasn't saved any places yet.")
                }
                .padding(.top, 40)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(friendWishlistVM.items) { item in
                        BucketItemRow(
                            placeName: item.placeName,
                            address: item.address,
                            vibeTag: item.vibeTag,
                            dateSaved: item.dateSaved
                        )
                        .padding(.horizontal)
                        Divider().padding(.leading)
                    }
                }
            }
        }
        .onAppear { friendWishlistVM.load(for: viewModel.user.uid) }
    }

    var emptyStateView: some View {
        ContentUnavailableView(
            "No Vibes Yet",
            systemImage: "photo.on.rectangle",
            description: Text("Shared vibes will appear here.")
        )
        .padding(.top, 40)
    }

    var followButton: some View {
        Button {
            viewModel.isFollowing ? viewModel.unfollow() : viewModel.follow()
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


struct PostGridItem: View {
    let post: Post

    var body: some View {
        WebImage(url: URL(string: post.imageUrl)) { image in
            image.resizable()
        } placeholder: {
            Color.gray.opacity(0.1)
        }
        .transition(.fade(duration: 0.5))
        .aspectRatio(contentMode: .fill)
        .frame(
            width:  UIScreen.main.bounds.width / 3,
            height: UIScreen.main.bounds.width / 3
        )
        .clipped()
    }
}


enum UserListMode {
    case followers, following
}

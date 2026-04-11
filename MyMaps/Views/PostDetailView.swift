//
//  PostDetailView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/1/26.
//

import SwiftUI
import SDWebImageSwiftUI
import MapKit

struct PostDetailView: View {
    @StateObject var viewModel: PostDetailViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @State private var isSavedToBucket = false
    @State private var showComments = false
    @State private var showOwnerActions = false
    @State private var isLiked: Bool
    @State private var likeCount: Int

    var onUpdate: (Post) -> Void

    private let likeRepository   = LikeRepository()
    private let wishlistService  = WishlistService()

    init(viewModel: PostDetailViewModel, onUpdate: @escaping (Post) -> Void) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onUpdate   = onUpdate
        let currentUserId = AuthViewModel.shared.userSession?.uid ?? ""
        self._isLiked   = State(initialValue: viewModel.post.isLiked(by: currentUserId))
        self._likeCount = State(initialValue: viewModel.post.likes.count)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                imageSection
                actionBar
                VStack(alignment: .leading, spacing: 12) {
                    likesSection
                    captionSection
                    ratingSection
                    locationSection
                    Divider()
                    commentsPreview
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.isOwner {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showOwnerActions = true } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
        }
        .sheet(isPresented: $showComments) {
            CommentsView(
                viewModel: CommentsViewModel(postId: viewModel.post.id ?? ""),
                post: viewModel.post
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.isEditing) {
            EditPostView(post: viewModel.post) { updatedPost in
                viewModel.post = updatedPost
                onUpdate(updatedPost)
            }
        }
        .confirmationDialog("Post Options", isPresented: $showOwnerActions, titleVisibility: .hidden) {
            Button("Edit Post")   { viewModel.isEditing = true }
            Button("Delete Post", role: .destructive) { viewModel.showDeleteConfirmation = true }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Delete Post?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Delete", role: .destructive) { viewModel.deletePost { dismiss() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure? This memory will be gone forever.")
        }
        .onAppear {
            viewModel.fetchAuthorName()
            isSavedToBucket = wishlistService.checkIfSaved(
                placeName: viewModel.post.placeName,
                context: viewContext
            )
        }
        .onChange(of: viewModel.post.likes.count) { _, newValue in likeCount = newValue }
    }
}

private extension PostDetailView {

    var headerSection: some View {
        HStack(spacing: 10) {
            HStack(spacing: 10) {
                UserAvatarView(profileImageUrl: viewModel.authorProfileImageUrl, size: 36)
                VStack(alignment: .leading, spacing: 1) {
                    Text(viewModel.authorName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(viewModel.post.placeName)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    var imageSection: some View {
        WebImage(url: URL(string: viewModel.post.imageUrl)) { image in
            image.resizable()
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .overlay(Image(systemName: "photo").foregroundStyle(.gray))
        }
        .aspectRatio(contentMode: .fill)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        .clipped()
    }

    var actionBar: some View {
        HStack(spacing: 18) {
            Button { handleLikeTapped() } label: {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundStyle(isLiked ? .red : .primary)
                    .font(.system(size: 24))
            }
            Button { showComments = true } label: {
                Image(systemName: "bubble.right")
                    .font(.system(size: 22))
                    .foregroundStyle(.primary)
            }
            Spacer()
            if !viewModel.isOwner {
                Button { toggleBucketSave() } label: {
                    Image(systemName: isSavedToBucket ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 22))
                        .foregroundStyle(isSavedToBucket ? .orange : .primary)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    var likesSection: some View {
        Group {
            if likeCount > 0 {
                Text("\(likeCount) \(likeCount == 1 ? "like" : "likes")")
                    .font(.system(size: 13, weight: .semibold))
            }
        }
    }

    var captionSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            (Text(viewModel.authorName).bold() + Text("  \(viewModel.post.caption)"))
                .font(.system(size: 14))
            Text(viewModel.post.vibe.displayName)
                .font(.system(size: 11, weight: .black))
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(viewModel.post.vibe.color.opacity(0.12))
                .foregroundStyle(viewModel.post.vibe.color)
                .clipShape(Capsule())
        }
    }

    var ratingSection: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= viewModel.post.rating ? "star.fill" : "star")
                    .font(.system(size: 14))
                    .foregroundStyle(star <= viewModel.post.rating ? Color.orange : Color.gray.opacity(0.4))
            }
            Text("\(viewModel.post.rating)/5")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .padding(.leading, 2)
        }
    }

    var locationSection: some View {
        Button { viewModel.openInMaps() } label: {
            HStack(spacing: 6) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(.red)
                    .font(.system(size: 16))
                VStack(alignment: .leading, spacing: 1) {
                    Text(viewModel.post.placeName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary)
                    Text(viewModel.post.address)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .padding(10)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    var commentsPreview: some View {
        Button { showComments = true } label: {
            Text("View all comments")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
    }
}

private extension PostDetailView {

    func toggleBucketSave() {
        HapticManager.trigger(.medium)
        let currentUserId = authViewModel.currentUser?.uid ?? ""
        guard !currentUserId.isEmpty else { return }

        if isSavedToBucket {
            wishlistService.removeByPlaceName(
                placeName: viewModel.post.placeName,
                currentUserId: currentUserId,
                context: viewContext
            )
            isSavedToBucket = false
        } else {
            wishlistService.add(
                placeName:    viewModel.post.placeName,
                address:      viewModel.post.address,
                vibeRawValue: viewModel.post.vibe.rawValue,
                currentUserId: currentUserId,
                context: viewContext
            )
            isSavedToBucket = true
        }
    }

    func handleLikeTapped() {
        guard let postId = viewModel.post.id else { return }
        let currentUserId = authViewModel.currentUser?.uid ?? ""
        guard !currentUserId.isEmpty else { return }

        HapticManager.trigger(.medium)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            isLiked.toggle()
            likeCount += isLiked ? 1 : -1
        }
        Task {
            try? await likeRepository.toggleLike(
                postId: postId,
                currentUserId: currentUserId,
                currentlyLiked: !isLiked
            )
        }
    }
}

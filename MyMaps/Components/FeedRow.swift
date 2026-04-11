//
//  FeedRow.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/31/26.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore

struct FeedRow: View {
    let post: Post

    @State private var showComments = false
    @State private var previewComments: [Comment] = []
    @State private var commentListener: ListenerRegistration?
    @State private var isLiked: Bool
    @State private var likeCount: Int
    @State private var resolvedAvatarUrl: String?

    private let likeRepository    = LikeRepository()
    private let commentRepository = CommentRepository()
    private let userRepository    = UserRepository()

    init(post: Post) {
        self.post = post
        let currentUserId = AuthViewModel.shared.userSession?.uid ?? ""
        self._isLiked          = State(initialValue: post.isLiked(by: currentUserId))
        self._likeCount        = State(initialValue: post.likes.count)
        self._resolvedAvatarUrl = State(initialValue: post.authorProfileImageUrl)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            headerSection
            imageSection
            interactionButtons
            likesSection
            captionSection
            commentPreviewSection
        }
        .padding(.bottom, 12)
        .sheet(isPresented: $showComments) {
            CommentsView(
                viewModel: CommentsViewModel(postId: post.id ?? ""),
                post: post
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            setupCommentListener()
            fetchAvatarIfNeeded()
        }
        .onDisappear { commentListener?.remove() }
        .onChange(of: post.likes.count) { _, newValue in likeCount = newValue }
    }
}

private extension FeedRow {

    var headerSection: some View {
        HStack(spacing: 10) {
            HStack(spacing: 10) {
                UserAvatarView(profileImageUrl: resolvedAvatarUrl, size: 34)
                Text(post.authorName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
            }

            Text(post.placeName)
                .font(.system(size: 12))
                .foregroundStyle(.blue)

            Spacer()

            Text(post.createdAt.timeAgoDisplay())
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
    }

    var imageSection: some View {
        WebImage(url: URL(string: post.imageUrl)) { image in
            image.resizable()
        } placeholder: {
            Rectangle().fill(Color.gray.opacity(0.1))
        }
        .aspectRatio(contentMode: .fill)
        .frame(width: UIScreen.main.bounds.width, height: 400)
        .clipped()
    }

    var interactionButtons: some View {
        HStack(spacing: 18) {
            Button { handleLikeTapped() } label: {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundStyle(isLiked ? .red : .primary)
            }
            Button { showComments.toggle() } label: {
                Image(systemName: "bubble.right")
            }
            Image(systemName: "paperplane")
            Spacer()
            Image(systemName: "bookmark")
        }
        .buttonStyle(.plain)
        .font(.system(size: 20))
        .padding(.horizontal, 12)
        .padding(.top, 2)
    }

    var likesSection: some View {
        Group {
            if likeCount > 0 {
                Text("\(likeCount) \(likeCount == 1 ? "like" : "likes")")
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 12)
            }
        }
    }

    var captionSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            (Text(post.authorName).bold() + Text("  \(post.caption)"))
                .font(.system(size: 14))
            Text(post.vibe.displayName)
                .font(.system(size: 10, weight: .black))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(post.vibe.color.opacity(0.1))
                .foregroundStyle(post.vibe.color)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 12)
    }

    var commentPreviewSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if previewComments.count > 2 {
                Button { showComments.toggle() } label: {
                    Text("View all \(previewComments.count) comments")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                }
                .buttonStyle(.plain)
            }
            ForEach(previewComments.prefix(2)) { comment in
                (Text(comment.authorUsername).bold() + Text(" \(comment.commentText)"))
                    .font(.system(size: 14))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 12)
    }
}

private extension FeedRow {

    func handleLikeTapped() {
        guard let postId = post.id else { return }
        let currentUserId = AuthViewModel.shared.userSession?.uid ?? ""
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

    func fetchAvatarIfNeeded() {
        guard resolvedAvatarUrl == nil else { return }
        Task {
            if let user = try? await userRepository.fetchUser(uid: post.authorId) {
                resolvedAvatarUrl = user.profileImageUrl
            }
        }
    }

    func setupCommentListener() {
        guard let postId = post.id else { return }
        commentListener?.remove()
        commentListener = commentRepository.observeComments(postId: postId) { comments in
            self.previewComments = comments.sorted { $0.timestamp > $1.timestamp }
        }
    }
}

//
//  CommentsView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/01/26.
//

import SwiftUI

struct CommentsView: View {
    @ObservedObject var viewModel: CommentsViewModel
    let post: Post

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            if viewModel.comments.isEmpty {
                emptyState
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(viewModel.comments) { comment in
                                commentRow(comment).id(comment.id)
                                Divider().padding(.leading, 58)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .onChange(of: viewModel.comments.count) { _, _ in
                        withAnimation { proxy.scrollTo(viewModel.comments.last?.id, anchor: .bottom) }
                    }
                }
            }

            commentInputBar
        }
        .onAppear  { viewModel.startListening() }
        .onDisappear { viewModel.stopListening() }
    }

    private var header: some View {
        Text("Comments")
            .font(.system(size: 15, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "bubble.right")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("No comments yet").font(.subheadline.bold())
            Text("Be the first to share your thoughts.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 60)
    }

    private func commentRow(_ comment: Comment) -> some View {
        HStack(alignment: .top, spacing: 12) {
            UserAvatarView(profileImageUrl: comment.profileImageUrl, size: 36)
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(comment.authorUsername)
                        .font(.system(size: 13, weight: .bold))
                    Text(comment.timestamp.timeAgoDisplay())
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                Text(comment.commentText)
                    .font(.system(size: 14))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var commentInputBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 10) {
                if let user = AuthViewModel.shared.currentUser {
                    UserAvatarView(profileImageUrl: user.profileImageUrl, size: 32)
                    HStack {
                        TextField("Add a comment…", text: $viewModel.commentText, axis: .vertical)
                            .font(.system(size: 14))
                            .lineLimit(1...4)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)

                        if !viewModel.commentText.isEmpty {
                            Button {
                                Task {
                                    await viewModel.submitComment(
                                        postOwnerId:    post.authorId,
                                        currentUserId:  user.uid,
                                        username:       user.username,
                                        profileImageUrl: user.profileImageUrl
                                    )
                                }
                            } label: {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                            }
                            .padding(.trailing, 6)
                        }
                    }
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .padding(.bottom, 4)
        }
    }
}

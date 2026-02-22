//
//  PostDetailView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/1/26.
//

import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseAuth


struct PostDetailView: View {
    @StateObject var viewModel: PostDetailViewModel
    @Environment(\.dismiss) var dismiss
    var onUpdate: (Post) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    PostHeaderImage(url: viewModel.post.imageUrl)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        PostTitleSection(
                            title: viewModel.post.placeName,
                            rating: viewModel.post.rating,
                            vibe: viewModel.post.vibe.rawValue
                        )
                        
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundStyle(.secondary)
                            Text("Posted by \(viewModel.authorName)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        
                        DirectionsButton(address: viewModel.post.address) {
                            viewModel.openInMaps()
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("The Vibe Check").font(.headline)
                            Text(viewModel.post.caption)
                                .font(.body)
                                .lineSpacing(4)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.isOwner { ownerMenu }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray.opacity(0.5))
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $viewModel.isEditing) {
                EditPostView(post: viewModel.post) { updatedPost in
                    viewModel.post = updatedPost
                    onUpdate(updatedPost)
                }
            }
            .alert("Delete Post?", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    viewModel.deletePost { dismiss() }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure? This memory will be gone forever.")
            }
            .onAppear { viewModel.fetchAuthorName() }
        }
    }

    private var ownerMenu: some View {
        Menu {
            Button { viewModel.isEditing = true } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) { viewModel.showDeleteConfirmation = true } label: {
                Label("Delete", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle").font(.title3)
        }
    }
}

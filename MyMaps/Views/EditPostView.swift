//
//  EditPostView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/2/26.
//

import SwiftUI
import SDWebImageSwiftUI

struct EditPostView: View {
    @StateObject private var viewModel: EditPostViewModel
    @Environment(\.dismiss) var dismiss
    var onSave: (Post) -> Void

    init(post: Post, onSave: @escaping (Post) -> Void) {
        _viewModel = StateObject(wrappedValue: EditPostViewModel(post: post))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    imageSection
                    Divider()
                    captionSection
                    Divider()
                    locationRow
                    Divider()
                    ratingRow
                    Divider()
                    vibeRow
                    Divider()
                }
            }
            .navigationTitle("Edit Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await viewModel.save { updatedPost in
                                onSave(updatedPost)
                                dismiss()
                            }
                        }
                    } label: {
                        if viewModel.isSaving {
                            ProgressView().tint(.blue)
                        } else {
                            Text("Save")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(viewModel.isSaveDisabled ? .gray : .blue)
                        }
                    }
                    .disabled(viewModel.isSaveDisabled)
                }
            }
        }
    }

    private var imageSection: some View {
        WebImage(url: URL(string: viewModel.post.imageUrl)) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Rectangle().fill(Color.gray.opacity(0.1))
                .overlay(Image(systemName: "photo").font(.largeTitle).foregroundStyle(.gray))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 320)
        .clipped()
    }

    private var captionSection: some View {
        HStack(alignment: .top, spacing: 12) {
            UserAvatarView(profileImageUrl: AuthViewModel.shared.currentUser?.profileImageUrl, size: 38)

            TextField("What's the vibe at this spot?", text: $viewModel.caption, axis: .vertical)
                .font(.system(size: 16))
                .lineLimit(4...)
                .padding(.top, 2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var locationRow: some View {
        HStack(spacing: 14) {
            Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .foregroundStyle(.red)

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.post.placeName)
                    .font(.subheadline.bold())
                Text(viewModel.post.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var ratingRow: some View {
        HStack(spacing: 14) {
            Image(systemName: "star.circle.fill")
                .font(.title2)
                .foregroundStyle(.orange)

            Text("Rating")
                .font(.subheadline.bold())

            Spacer()

            HStack(spacing: 6) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= viewModel.rating ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundStyle(star <= viewModel.rating ? Color.orange : Color.gray.opacity(0.3))
                        .onTapGesture {
                            HapticManager.trigger(.light)
                            viewModel.rating = star
                        }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var vibeRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 14) {
                Image(systemName: "flame.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                Text("Vibe")
                    .font(.subheadline.bold())
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(VibeCategory.allCases, id: \.self) { vibe in
                        VibeChip(vibe: vibe, isSelected: viewModel.selectedVibe == vibe) {
                            HapticManager.trigger(.light)
                            viewModel.selectedVibe = vibe
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 14)
    }
}

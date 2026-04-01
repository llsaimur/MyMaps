//
//  CreatePostView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/1/26.
//

import SwiftUI
import MapKit

struct CreatePostView: View {
    let coordinate: CLLocationCoordinate2D
    @StateObject private var viewModel = CreatePostViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    photoSection
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
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let uid = AuthViewModel.shared.userSession?.uid ?? ""
                        Task {
                            await viewModel.submitPost(currentUserId: uid)
                            if viewModel.uiState == .success { dismiss() }
                        }
                    } label: {
                        if viewModel.uiState == .uploading {
                            ProgressView().tint(.blue)
                        } else {
                            Text("Share")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(viewModel.isPostEnabled ? .blue : .gray)
                        }
                    }
                    .disabled(!viewModel.isPostEnabled || viewModel.uiState == .uploading)
                }
            }
            .sheet(isPresented: $viewModel.showSearch) {
                ManualSearchView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.initialCoordinate = coordinate
                viewModel.fetchLocationDetails(for: coordinate)
            }
            .onChange(of: viewModel.selectedImage) { _, newImage in
                if let image = newImage { viewModel.handlePhotoProcessing(image: image) }
            }
        }
    }

    private var photoSection: some View {
        Group {
            if let image = viewModel.selectedImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 320)
                        .clipped()

                    Button {
                        viewModel.selectedImage = nil
                        viewModel.validateInput()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white, Color.black.opacity(0.5))
                    }
                    .padding(12)
                }
            } else {
                PhotoPickerView(selectedImage: $viewModel.selectedImage)
                    .frame(height: 220)
            }
        }
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
        Button { viewModel.showSearch = true } label: {
            HStack(spacing: 14) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.red)

                VStack(alignment: .leading, spacing: 2) {
                    if viewModel.uiState == .loading {
                        HStack(spacing: 6) {
                            ProgressView().scaleEffect(0.8)
                            Text("Finding location…")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text(viewModel.detectedPlace?.name ?? "Add location")
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)
                        if let addr = viewModel.detectedPlace?.address {
                            Text(addr)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
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

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
                VStack(spacing: 24) {
                    
                    Group {
                        if let image = viewModel.selectedImage {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 250)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                
                                Button {
                                    viewModel.selectedImage = nil
                                    viewModel.validateInput()
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.white, .black.opacity(0.6))
                                        .font(.title)
                                }
                                .padding(8)
                            }
                        } else {
                            PhotoPickerView(selectedImage: $viewModel.selectedImage)
                                .frame(height: 200)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location Details").font(.headline)
                        HStack {
                            if viewModel.uiState == .loading {
                                ProgressView().padding(.trailing, 8)
                                Text("Identifying...").font(.subheadline).foregroundStyle(.secondary)
                            } else {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(viewModel.detectedPlace?.name ?? "Unknown Location")
                                        .font(.subheadline.bold())
                                    Text(viewModel.detectedPlace?.address ?? "No address found")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Button("Change") { viewModel.showSearch = true }
                                .font(.subheadline.bold())
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    StarRatingView(rating: $viewModel.rating)
                    
                    VibeSelector(selectedVibe: $viewModel.selectedVibe)
                    
                    AppTextField(
                        label: "Description",
                        placeholder: "What makes this place special?",
                        text: $viewModel.caption
                    )
                    
                    Button {
                        Task {
                            await viewModel.submitPost()
                            if viewModel.uiState == .success { dismiss() }
                        }
                    } label: {
                        if viewModel.uiState == .uploading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Post Memory").font(.headline).frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isPostEnabled ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(!viewModel.isPostEnabled || viewModel.uiState == .uploading)
                }
                .padding()
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
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
                if let image = newImage {
                    viewModel.handlePhotoProcessing(image: image)
                }
            }
        }
    }
}



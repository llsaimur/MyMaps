//
//  EditPostView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/2/26.
//


import SwiftUI
import FirebaseFirestore

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
                VStack(alignment: .leading, spacing: 24) {
                    StarRatingView(rating: $viewModel.rating, label: "Update Rating")
                    VibeSelector(selectedVibe: $viewModel.selectedVibe, label: "Update the Vibe")
                    AppTextField(label: "Description",
                                 placeholder: "Edit your caption...",
                                 text: $viewModel.caption)
                }
                .padding()
            }
            .navigationTitle("Edit Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.save { updatedPost in
                                onSave(updatedPost)
                                dismiss()
                            }
                        }
                    }
                    .bold()
                    .disabled(viewModel.isSaveDisabled)
                }
            }
            .overlay {
                if viewModel.isSaving {
                    ProgressView()
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
            }
        }
    }
}

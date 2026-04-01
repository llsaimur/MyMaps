//
//  SettingsView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/28/26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                profileSection
                accountSection
                dangerSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog(
                "Delete Account",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete My Account", role: .destructive) {
                    Task { await authViewModel.deleteAccount() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete your account and all your data. This cannot be undone.")
            }
        }
    }

    private var profileSection: some View {
        Section("Profile") {
            if let user = authViewModel.currentUser {
                LabeledContent("Username", value: "@\(user.username)")
                LabeledContent("Full Name", value: user.fullname)
                LabeledContent("Email", value: user.email)
            }
        }
    }

    private var accountSection: some View {
        Section("Account") {
            Button {
                authViewModel.signOut()
                dismiss()
            } label: {
                Label("Sign Out", systemImage: "arrow.backward.square")
                    .foregroundStyle(.primary)
            }
        }
    }

    private var dangerSection: some View {
        Section {
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete Account", systemImage: "trash")
            }
        } header: {
            Text("Danger Zone")
        } footer: {
            Text("Deleting your account is permanent and cannot be undone.")
        }
    }
}

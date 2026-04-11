//
//  ForgotPasswordView.swift
//  MyMaps
//

import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var email = ""
    @State private var isLoading = false
    @State private var didSend = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "lock.rotation")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(.blue)
                    .padding(.bottom, 4)

                Text("Forgot Password?")
                    .font(.system(size: 26, weight: .bold))

                Text("Enter your email and we'll send you a reset link.")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.top, 60)
            .padding(.bottom, 40)

            if didSend {
                sentConfirmation
            } else {
                inputSection
            }

            Spacer()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                }
            }
        }
    }

    // MARK: - Subviews

    private var inputSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                TextField("Email address", text: $email)
                    .font(.system(size: 15))
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 24)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Button {
                sendReset()
            } label: {
                Group {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Send Reset Link")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(email.isEmpty ? Color.blue.opacity(0.4) : Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(email.isEmpty || isLoading)
            .padding(.horizontal, 24)
        }
    }

    private var sentConfirmation: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 52))
                .foregroundStyle(.green)

            Text("Check your inbox")
                .font(.system(size: 20, weight: .semibold))

            Text("A password reset link was sent to\n**\(email)**")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                dismiss()
            } label: {
                Text("Back to Sign In")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
    }

    // MARK: - Actions

    private func sendReset() {
        isLoading = true
        Task {
            let success = await viewModel.sendPasswordReset(email: email)
            isLoading = false
            if success { didSend = true }
        }
    }
}

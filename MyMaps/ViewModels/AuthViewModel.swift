//
//  AuthViewModel.swift
//  MyMaps
//
//  Created by Saimur Rashid on 1/31/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {

    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var errorMessage: String?
    @Published var isLoading = false

    static let shared = AuthViewModel()

    private let authService      = AuthService()
    private let userRepository   = UserRepository()
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var userListener: ListenerRegistration?


    init() {
        authStateHandle = authService.addAuthStateListener { [weak self] user in
            Task { @MainActor in
                self?.userSession = user
                if let uid = user?.uid {
                    self?.startListeningToUser(uid: uid)
                } else {
                    self?.stopListeningToUser()
                }
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            authService.removeAuthStateListener(handle)
        }
        userListener?.remove()
    }


    func login(withEmail email: String, password: String) {
        errorMessage = nil
        isLoading = true
        Task {
            do {
                try await authService.signIn(email: email, password: password)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func register(withEmail email: String, password: String, username: String, fullname: String) {
        errorMessage = nil
        guard username.count >= 3 else {
            errorMessage = "Username must be at least 3 characters."
            return
        }
        isLoading = true
        Task {
            do {
                let uid = try await authService.createUser(email: email, password: password)
                try await userRepository.createUserDocument(
                    uid: uid,
                    email: email,
                    username: username,
                    fullname: fullname
                )
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func signOut() {
        stopListeningToUser()
        do {
            try authService.signOut()
            userSession = nil
            currentUser = nil
            errorMessage = nil
        } catch {
            errorMessage = "Error signing out."
        }
    }

    func deleteAccount() async {
        guard let uid = userSession?.uid else { return }
        do {
            try await userRepository.deleteUserDocument(uid: uid)
            try await authService.deleteCurrentUser()
            stopListeningToUser()
            userSession = nil
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }


    func updateProfile(fullname: String, username: String) {
        guard let uid = userSession?.uid else { return }
        Task {
            do {
                try await userRepository.updateProfile(uid: uid, fullname: fullname, username: username)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func uploadProfileImage(_ image: UIImage) async {
        guard let uid = userSession?.uid,
              let imageData = image.jpegData(compressionQuality: 0.6) else { return }
        do {
            let urlString = try await userRepository.uploadProfileImage(uid: uid, imageData: imageData)
            try await userRepository.updateProfileImageUrl(uid: uid, urlString: urlString)
            currentUser?.profileImageUrl = urlString
        } catch {
            print("DEBUG AuthViewModel: Profile image upload failed — \(error.localizedDescription)")
        }
    }


    private func startListeningToUser(uid: String) {
        // Remove any stale listener before starting a fresh one.
        userListener?.remove()
        userListener = userRepository.observeUser(uid: uid) { [weak self] user in
            Task { @MainActor in
                self?.currentUser = user
            }
        }
    }

    private func stopListeningToUser() {
        userListener?.remove()
        userListener = nil
    }
}

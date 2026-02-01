//
//  AuthViewModel.swift
//  MyMaps
//
//  Created by Saimur Rashid on 1/31/26.
//


import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var errorMessage: String?
    
    static let shared = AuthViewModel()
    
    init() {
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.userSession = user
            if let uid = user?.uid {
                self?.fetchCurrentUser(withUid: uid)
            }
        }
    }
    
    // MARK: - Authentication
    
    func login(withEmail email: String, password: String) {
        self.errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            self?.errorMessage = nil
        }
    }
    
    func register(withEmail email: String, password: String, username: String) {
        self.errorMessage = nil
        
        if username.count < 3 {
            self.errorMessage = "Username too short."
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            
            guard let uid = result?.user.uid else { return }
            self?.uploadUserData(uid: uid, email: email, username: username)
        }
    }
    
    private func uploadUserData(uid: String, email: String, username: String) {
        let data: [String: Any] = [
            "email": email,
            "username": username.lowercased(),
            "uid": uid,
            "followingCount": 0,
            "followerCount": 0
        ]
        
        Firestore.firestore().collection("users").document(uid).setData(data) { [weak self] error in
            if let error = error {
                self?.errorMessage = "Database error: \(error.localizedDescription)"
            } else {
                self?.errorMessage = nil
            }
        }
    }
    
    func fetchCurrentUser(withUid uid: String) {
        Firestore.firestore().collection("users").document(uid).addSnapshotListener { snapshot, _ in
            guard let user = try? snapshot?.data(as: User.self) else { return }
            self.currentUser = user
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            
            self.userSession = nil
            self.currentUser = nil
            self.errorMessage = nil
            
        } catch {
            print("DEBUG: Failed to sign out with error: \(error.localizedDescription)")
            self.errorMessage = "Error signing out. Please try again."
        }
    }
}

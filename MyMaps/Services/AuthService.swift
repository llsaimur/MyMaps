//
//  AuthService.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/31/26.
//

import FirebaseAuth

struct AuthService {

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func createUser(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user.uid
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func deleteCurrentUser() async throws {
        guard let user = Auth.auth().currentUser else { return }
        try await user.delete()
    }

    @discardableResult
    func addAuthStateListener(_ handler: @escaping (FirebaseAuth.User?) -> Void) -> AuthStateDidChangeListenerHandle {
        Auth.auth().addStateDidChangeListener { _, user in
            handler(user)
        }
    }

    func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
    }

    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
}

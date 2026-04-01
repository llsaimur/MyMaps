//
//  UserListViewModel.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/31/26.
//

import Foundation

@MainActor
class UserListViewModel: ObservableObject {

    @Published var users: [User] = []
    @Published var isLoading = false

    private let userRepository = UserRepository()

    func load(userIds: [String]) async {
        guard !userIds.isEmpty else {
            isLoading = false
            return
        }
        isLoading = true
        do {
            users = try await userRepository.fetchUsers(byIds: userIds)
        } catch {
            print("DEBUG UserListViewModel: load — \(error.localizedDescription)")
        }
        isLoading = false
    }
}

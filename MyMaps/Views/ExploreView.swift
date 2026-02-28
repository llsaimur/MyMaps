//
//  ExploreView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/22/26.
//

import SwiftUI
import FirebaseFirestore

struct ExploreView: View {
    @State private var searchText = ""
    @State private var users = [User]()
    @State private var listener: ListenerRegistration?
    
    @State private var followingState: [String: Bool] = [:]
    
    var body: some View {
        NavigationStack {
            List(users, id: \.uid) { user in
                HStack(spacing: 12) {
                    NavigationLink(destination: ProfileView(viewModel: ProfileViewModel(user: user))) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(.gray.opacity(0.3))
                            
                            VStack(alignment: .leading) {
                                Text(user.username).font(.subheadline).bold()
                                Text(user.email).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if !user.isCurrentUser {
                        followButton(for: user)
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Search Vibes")
            .searchable(text: $searchText, prompt: "Find friends...")
            .listStyle(.plain)
            .onChange(of: searchText) { _, newValue in
                startSearching(query: newValue.lowercased())
            }
        }
    }
    
    @ViewBuilder
    private func followButton(for user: User) -> some View {
        let isFollowing = followingState[user.uid] ?? false
        
        Button {
            handleFollowTap(for: user, currentlyFollowing: isFollowing)
        } label: {
            Text(isFollowing ? "Following" : "Follow")
                .font(.caption).bold()
                .frame(width: 85, height: 30)
                .foregroundStyle(isFollowing ? Color.primary : Color.white)
                .background(isFollowing ? Color.gray.opacity(0.2) : Color.blue)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
    
    private func handleFollowTap(for user: User, currentlyFollowing: Bool) {
        Task {
            followingState[user.uid] = !currentlyFollowing
            HapticManager.trigger(.light)
            
            do {
                if currentlyFollowing {
                    try await SocialService.unfollow(uid: user.uid)
                } else {
                    try await SocialService.follow(uid: user.uid)
                }
            } catch {
                followingState[user.uid] = currentlyFollowing
            }
        }
    }
    
    private func startSearching(query: String) {
        listener?.remove()
        guard !query.isEmpty else { users = []; return }

        listener = Firestore.firestore().collection("users")
            .whereField("username", isGreaterThanOrEqualTo: query)
            .whereField("username", isLessThanOrEqualTo: query + "\u{f8ff}")
            .addSnapshotListener { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let fetchedUsers = documents.compactMap { try? $0.data(as: User.self) }
                self.users = fetchedUsers
                
                for user in fetchedUsers {
                    Task {
                        let following = try? await SocialService.checkIfFollowing(uid: user.uid)
                        await MainActor.run {
                            followingState[user.uid] = following ?? false
                        }
                    }
                }
            }
    }
}

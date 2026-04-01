//
//  User.swift
//  MyMaps
//
//  Created by Saimur Rashid on 1/31/26.
//


import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let uid: String
    var username: String
    var fullname: String
    let email: String
    var profileImageUrl: String?
    var followingCount: Int
    var followerCount: Int
    var followingIDs: [String] = []
    var followerIDs: [String] = []

    func isCurrentUser(id currentUserId: String) -> Bool {
        uid == currentUserId
    }
}

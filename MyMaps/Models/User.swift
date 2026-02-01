//
//  User.swift
//  MyMaps
//
//  Created by Saimur Rashid on 1/31/26.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let uid: String
    var username: String
    let email: String
    var profileImageUrl: String?
    var followingCount: Int
    var followerCount: Int
    
    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == uid
    }
}

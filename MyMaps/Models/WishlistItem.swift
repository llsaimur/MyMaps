//
//  WishlistItem.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/28/26.
//

import Foundation

struct WishlistItem: Identifiable, Codable {
    var id: String
    var placeName: String
    var address: String
    var vibeTag: String
    var dateSaved: Date
}

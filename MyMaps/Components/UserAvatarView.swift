//
//  UserAvatarView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/28/26.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserAvatarView: View {
    let profileImageUrl: String?
    let size: CGFloat

    var body: some View {
        if let urlString = profileImageUrl, let url = URL(string: urlString) {
            WebImage(url: url)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: size, height: size)
                .foregroundStyle(.gray.opacity(0.3))
        }
    }
}

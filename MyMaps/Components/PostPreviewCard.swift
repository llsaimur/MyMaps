//
//  PostPreviewCard.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/30/26.
//

import SwiftUI
import SDWebImageSwiftUI

struct PostPreviewCard: View {
    let post: Post
    let onDismiss: () -> Void
    let onViewPost: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                WebImage(url: URL(string: post.imageUrl)) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .overlay(Image(systemName: "photo").foregroundStyle(.gray))
                }
                .frame(width: 76, height: 76)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 5) {
                    Text(post.placeName)
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(1)

                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= post.rating ? "star.fill" : "star")
                                .font(.system(size: 11))
                                .foregroundStyle(star <= post.rating ? Color.orange : Color.gray.opacity(0.4))
                        }
                    }

                    Text(post.vibe.displayName)
                        .font(.system(size: 10, weight: .black))
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(post.vibe.color.opacity(0.12))
                        .foregroundStyle(post.vibe.color)
                        .clipShape(Capsule())

                    Text(post.address)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.secondary)
                }
            }
            .padding()

            Divider()

            Button(action: onViewPost) {
                HStack(spacing: 6) {
                    Text("View Post")
                        .font(.system(size: 14, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
    }
}

//
//  VibeAnnotationView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/1/26.
//

import SwiftUI
import SDWebImageSwiftUI

struct PhotoAnnotationView: View {
    let imageUrl: String

    var body: some View {
        VStack(spacing: 0) {
            WebImage(url: URL(string: imageUrl)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                    )
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)

            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 10, height: 10)
                .rotationEffect(.degrees(180))
                .offset(y: -3)
                .shadow(color: Color.black.opacity(0.2), radius: 1)
        }
    }
}

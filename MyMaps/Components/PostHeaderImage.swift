//
//  PostHeaderImage.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/16/26.
//

import SwiftUI

struct PostHeaderImage: View {
    let url: String
    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
            image.resizable().aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle().fill(Color(.systemGray6)).overlay(ProgressView())
        }
        .frame(height: 350).clipped()
    }
}

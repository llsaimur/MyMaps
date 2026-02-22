//
//  PostTitleSection.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/16/26.
//

import SwiftUI

struct PostTitleSection: View {
    let title: String
    let rating: Int
    let vibe: String
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.title2.bold())
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(index <= rating ? .yellow : .gray.opacity(0.5))
                    }
                }
            }
            Spacer()
            Text(vibe)
                .font(.caption.bold())
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue).clipShape(Capsule())
        }
    }
}

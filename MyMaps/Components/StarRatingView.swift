//
//  StarRatingView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/2/26.
//

import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Int
    var label: String = "Rating"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.headline)
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .foregroundColor(index <= rating ? .yellow : .gray.opacity(0.3))
                        .font(.title2)
                        .onTapGesture {
                            HapticManager.trigger(.light)
                            rating = index
                        }
                }
            }
        }
    }
}

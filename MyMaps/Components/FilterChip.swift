//
//  FilterChip.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/15/26.
//

import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .blue
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color(.systemBackground).opacity(0.8))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
                .shadow(radius: 2)
        }
    }
}

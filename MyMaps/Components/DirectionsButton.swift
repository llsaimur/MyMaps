//
//  DirectionsButton.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/16/26.
//

import SwiftUI

struct DirectionsButton: View {
    let address: String
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(address).font(.subheadline).foregroundStyle(.secondary)
            Button(action: action) {
                Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue).foregroundColor(.white).cornerRadius(10)
            }
        }
    }
}

//
//  BucketItemRow.swift
//  MyMaps
//
//  Created by Saimur Rashid on 1/31/26.
//

import SwiftUI

struct BucketItemRow: View {
    let placeName: String
    let address: String
    let vibeTag: String
    let dateSaved: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(placeName)
                    .font(.headline)
                Spacer()
                Text(vibeTag)
                    .font(.system(size: 10, weight: .black))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
            }

            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse").font(.caption)
                Text(address).font(.caption)
            }
            .foregroundStyle(.secondary)

            Text("Saved on \(dateSaved.formatted(date: .abbreviated, time: .omitted))")
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

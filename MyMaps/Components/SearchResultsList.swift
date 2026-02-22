//
//  SearchResultsList.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/16/26.
//

import SwiftUI
import MapKit
import CoreLocation

struct SearchResultsList: View {
    let results: [MKMapItem]
    let onSelect: (MKMapItem) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(results, id: \.self) { item in
                    Button { onSelect(item) } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name ?? "Unknown Place")
                                .font(.headline).foregroundStyle(.primary)
                            Text(item.placemark.title ?? "")
                                .font(.caption).foregroundStyle(.secondary)
                                .lineLimit(1)
                            Divider().padding(.top, 8)
                        }
                        .padding([.horizontal, .top])
                        .contentShape(Rectangle())
                    }
                }
            }
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .frame(maxHeight: 300)
    }
}

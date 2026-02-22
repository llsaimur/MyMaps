//
//  PlacePreviewCard.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/16/26.
//

import SwiftUI
import MapKit
import CoreLocation

struct PlacePreviewCard: View {
    let place: MKMapItem
    let onCancel: () -> Void
    let onCreatePost: (CLLocationCoordinate2D) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name ?? "Selected Location").font(.headline)
                    Text(place.placemark.title ?? "").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray.opacity(0.5))
                        .font(.title2)
                }
            }
            
            Button {
                onCreatePost(place.placemark.coordinate)
            } label: {
                Text("Create Post Here")
                    .bold().foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.blue).cornerRadius(12)
            }
        }
        .padding(20)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

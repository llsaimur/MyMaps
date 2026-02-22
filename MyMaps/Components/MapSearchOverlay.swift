//
//  MapSearchOverlay.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/16/26.
//


import SwiftUI
import MapKit

struct MapSearchOverlay: View {
    @ObservedObject var viewModel: MapViewModel
    @FocusState.Binding var isSearchFocused: Bool
    let user: User
    var onSignOut: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search for a place...", text: $viewModel.searchText)
                    .focused($isSearchFocused)
                    .autocorrectionDisabled()
                
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                        isSearchFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                }
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5)
            
            Button(action: onSignOut) {
                Text(user.username.prefix(1).uppercased())
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
    }
}



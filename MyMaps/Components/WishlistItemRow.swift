//
//  WishlistItemRow.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/31/26.
//

import SwiftUI
import MapKit
import CoreData

struct WishlistItemRow: View {
    let item: BucketItem
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.managedObjectContext) private var viewContext

    @State private var showVisitedDialog = false
    @State private var showCreatePost = false
    @State private var postCoordinate = CLLocationCoordinate2D()

    private let wishlistService = WishlistService()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            BucketItemRow(
                placeName: item.placeName ?? "Unknown Location",
                address:   item.address  ?? "",
                vibeTag:   item.vibeTag  ?? "",
                dateSaved: item.dateSaved ?? Date()
            )

            HStack(spacing: 0) {
                actionButton("Directions", icon: "mappin.and.ellipse", color: .blue) {
                    openDirections()
                }
                Divider().frame(height: 22)
                actionButton("Visited", icon: "checkmark.circle", color: .green) {
                    showVisitedDialog = true
                }
                Divider().frame(height: 22)
                actionButton("Remove", icon: "trash", color: .red) {
                    removeItem()
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.vertical, 4)
        .confirmationDialog(
            "Mark \(item.placeName ?? "this place") as visited?",
            isPresented: $showVisitedDialog,
            titleVisibility: .visible
        ) {
            Button("Create a Post") { geocodeAndShowCreatePost() }
            Button("Just Remove", role: .destructive) { removeItem() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Want to share your experience?")
        }
        .sheet(isPresented: $showCreatePost, onDismiss: removeItem) {
            CreatePostView(coordinate: postCoordinate)
        }
    }


    private func actionButton(
        _ title: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 16))
                Text(title).font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    private func openDirections() {
        let query = [item.placeName, item.address].compactMap { $0 }.joined(separator: ", ")
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "maps://?daddr=\(encoded)") else { return }
        UIApplication.shared.open(url)
    }

    private func geocodeAndShowCreatePost() {
        let query = [item.placeName, item.address].compactMap { $0 }.joined(separator: ", ")
        CLGeocoder().geocodeAddressString(query) { placemarks, _ in
            postCoordinate = placemarks?.first?.location?.coordinate ?? CLLocationCoordinate2D()
            showCreatePost = true
        }
    }

    private func removeItem() {
        let currentUserId = authViewModel.currentUser?.uid ?? ""
        wishlistService.remove(item: item, currentUserId: currentUserId, context: viewContext)
    }
}

//
//  ProfileMapView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/31/26.
//

import SwiftUI
import MapKit
import CoreData

struct ProfileMapView: View {
    let posts: [Post]

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BucketItem.dateSaved, ascending: false)],
        animation: .default)
    private var wishlistItems: FetchedResults<BucketItem>

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var previewPost: Post?
    @State private var detailPost: Post?

    var body: some View {
        ZStack(alignment: .bottom) {
            map
            if let post = previewPost {
                previewCard(for: post)
            }
        }
        .sheet(item: $detailPost) { post in
            NavigationStack {
                PostDetailView(viewModel: PostDetailViewModel(post: post), onUpdate: { _ in })
            }
        }
    }

    private var map: some View {
        Map(position: $cameraPosition) {
            ForEach(posts) { post in
                Annotation(post.placeName, coordinate: post.coordinate) {
                    PhotoAnnotationView(imageUrl: post.imageUrl)
                        .onTapGesture {
                            HapticManager.trigger(.light)
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                previewPost = previewPost?.id == post.id ? nil : post
                            }
                        }
                }
            }
            ForEach(Array(wishlistItems), id: \.objectID) { item in
                Annotation(item.placeName ?? "", coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)) {
                    Image(systemName: "star.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.blue)
                        .background(Color.white.clipShape(Circle()))
                }
            }
        }
        .onAppear {
            if let first = posts.first {
                cameraPosition = .region(MKCoordinateRegion(
                    center: first.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
                ))
            }
        }
    }

    private func previewCard(for post: Post) -> some View {
        PostPreviewCard(post: post) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { previewPost = nil }
        } onViewPost: {
            detailPost = post
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
        .transition(.scale(scale: 0.85, anchor: .bottom).combined(with: .opacity))
    }
}

//
//  HomeView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/1/26.
//


import SwiftUI
import MapKit

struct HomeView: View {
    let user: User
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var locationManager = LocationManager()
    @StateObject private var mapViewModel = MapViewModel()
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var selectedPost: Post? = nil
    @State private var previewPlace: MKMapItem? = nil
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MapReader { proxy in
                Map(position: $cameraPosition) {
                    UserAnnotation()
                    
                    if let preview = previewPlace {
                        Annotation(preview.name ?? "", coordinate: preview.placemark.coordinate) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.title).foregroundStyle(.red).shadow(radius: 3)
                        }
                    }
                    
                    ForEach(mapViewModel.posts) { post in
                        Annotation(post.placeName, coordinate: post.location.coordinate) {
                            VibeAnnotationView(vibe: post.vibe)
                                .onTapGesture {
                                    HapticManager.trigger(.medium)
                                    selectedPost = post
                                }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .onMapCameraChange { visibleRegion = $0.region }
                .onTapGesture { screenPoint in
                    isSearchFocused = false
                    if previewPlace != nil { withAnimation { previewPlace = nil } }
                }
            }
            .ignoresSafeArea()

            VStack {
                MapSearchOverlay(
                    viewModel: mapViewModel,
                    isSearchFocused: $isSearchFocused,
                    user: user,
                    onSignOut: { authViewModel.signOut() }
                )
                
                if isSearchFocused && !mapViewModel.searchResults.isEmpty {
                    SearchResultsList(results: mapViewModel.searchResults, onSelect: handleSearchSelection)
                }
                Spacer()
            }
            .padding(.top, 10)
            
            VStack {
                if previewPlace == nil && !isSearchFocused {
                    createFloatingButton
                }
                
                if let place = previewPlace {
                    PlacePreviewCard(
                        place: place,
                        onCancel: { withAnimation { previewPlace = nil } },
                        onCreatePost: { coords in
                            previewPlace = nil
                            mapViewModel.selectedLocation = SelectedLocation(coordinate: coords)
                        }
                    )
                }
            }
        }
        .onAppear {
            locationManager.requestLocationPermission()
            mapViewModel.listenForPosts()
        }
        .onChange(of: locationManager.userLocation) { old, new in
            if let loc = new, old == nil { moveToLocation(loc.coordinate) }
        }
        .sheet(item: $mapViewModel.selectedLocation) { selection in
            CreatePostView(coordinate: selection.coordinate)
        }
        .sheet(item: $selectedPost) { post in
            PostDetailView(
                viewModel: PostDetailViewModel(post: post),
                onUpdate: { updatedPost in
                    if let index = mapViewModel.posts.firstIndex(where: { $0.id == updatedPost.id }) {
                        mapViewModel.posts[index] = updatedPost
                    }
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
    
    private var createFloatingButton: some View {
        Button {
            if let center = visibleRegion?.center {
                HapticManager.trigger(.heavy)
                mapViewModel.selectedLocation = SelectedLocation(coordinate: center)
            }
        } label: {
            Label("Post a Vibe", systemImage: "plus.circle.fill")
                .font(.headline).padding(.vertical, 12).padding(.horizontal, 20)
                .foregroundStyle(.white).background(Color.blue).clipShape(Capsule()).shadow(radius: 10)
        }
        .padding(.trailing, 16).padding(.bottom, 30)
    }
    
    private func handleSearchSelection(_ item: MKMapItem) {
        isSearchFocused = false
        mapViewModel.searchText = ""
        withAnimation(.spring()) { previewPlace = item }
        moveToLocation(item.placemark.coordinate)
    }

    private func moveToLocation(_ coordinate: CLLocationCoordinate2D) {
        withAnimation(.easeInOut(duration: 1.0)) {
            cameraPosition = .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            ))
        }
    }
}

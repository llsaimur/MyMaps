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
    @StateObject private var mapViewModel: MapViewModel

    @State private var cameraPosition: MapCameraPosition = .automatic

    init(user: User) {
        self.user = user
        _mapViewModel = StateObject(wrappedValue: MapViewModel(currentUserId: user.uid))
    }
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var selectedPost: Post? = nil
    @State private var detailPost: Post? = nil
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
                            PhotoAnnotationView(imageUrl: post.imageUrl)
                                .onTapGesture {
                                    HapticManager.trigger(.medium)
                                    selectedPost = post
                                }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .onMapCameraChange { visibleRegion = $0.region }
                .onTapGesture { _ in
                    isSearchFocused = false
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        previewPlace = nil
                        selectedPost = nil
                    }
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                MapSearchOverlay(
                    viewModel: mapViewModel,
                    isSearchFocused: $isSearchFocused,
                    user: user,
                    onSignOut: { authViewModel.signOut() }
                )
                
                if isSearchFocused && !mapViewModel.searchResults.isEmpty {
                    SearchResultsList(results: mapViewModel.searchResults, onSelect: handleSearchSelection)
                }
                
                if !isSearchFocused {
                    filterBar
                        .transition(.move(edge: .top).combined(with: .opacity))
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
            mapViewModel.listenForFriendPosts()
        }
        .onChange(of: locationManager.userLocation) { old, new in
            if let loc = new, old == nil { moveToLocation(loc.coordinate) }
        }
        .sheet(item: $mapViewModel.selectedLocation) { selection in
            CreatePostView(coordinate: selection.coordinate)
        }
        .sheet(item: $detailPost) { post in
            NavigationStack {
                PostDetailView(viewModel: PostDetailViewModel(post: post), onUpdate: { _ in })
            }
        }
        .overlay(alignment: .bottom) {
            if let post = selectedPost {
                PostPreviewCard(post: post) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { selectedPost = nil }
                } onViewPost: {
                    detailPost = post
                    selectedPost = nil
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 80)
                .transition(.scale(scale: 0.85, anchor: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: selectedPost?.id)
    }
    
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                filterChip(title: "Friends", icon: "person.2.fill", category: nil)
                
                ForEach(VibeCategory.allCases, id: \.self) { category in
                    filterChip(title: category.displayName, icon: category.icon, category: category)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
    
    private func filterChip(title: String, icon: String, category: VibeCategory?) -> some View {
        let isSelected = mapViewModel.selectedCategory == category
        let color = category?.color ?? .blue
        
        return Button {
            withAnimation(.spring()) {
                mapViewModel.updateFilter(to: category)
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 14, weight: .bold))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color(.systemBackground).opacity(0.9))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
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
        .padding(.trailing, 16)
        .padding(.bottom, 65)
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

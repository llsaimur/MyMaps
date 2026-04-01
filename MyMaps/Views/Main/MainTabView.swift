//
//  MainTabView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/22/26.
//


import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        if let user = authViewModel.currentUser {
            TabView {
                HomeView(user: user)
                    .tabItem {
                        Label("Map", systemImage: "map.fill")
                    }

                ExploreView()
                    .tabItem {
                        Label("Explore", systemImage: "magnifyingglass")
                    }
                
                DiscoveryView()
                    .tabItem {
                        Label("Discover", systemImage: "sparkles")
                    }
                
                NavigationStack {
                    ProfileView(viewModel: ProfileViewModel(user: user))
                }
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
            }
            .accentColor(.blue)
        } else {
            ProgressView("Session loading...")
        }
    }
}

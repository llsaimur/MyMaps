//
//  ContentView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 1/31/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @State private var showSplash = true

    var body: some View {
        Group {
            if showSplash {
                SplashView(isActive: $showSplash)
            } else if !hasCompletedOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else if authViewModel.userSession == nil {
                LoginView()
            } else {
                if let _ = authViewModel.currentUser {
                    MainTabView()
                        .transition(.opacity)
                } else {
                    ProgressView("Fetching your profile...")
                }
            }
        }
        .animation(.default, value: authViewModel.userSession)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel.shared)
}

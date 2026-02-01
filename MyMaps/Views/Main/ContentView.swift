//
//  ContentView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 1/31/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        Group {
                if !hasCompletedOnboarding {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                } else if authViewModel.userSession == nil {
                    LoginView()
                } else {
                    if let user = authViewModel.currentUser {
                        MainMapView(user: user)
                    } else {
                        ProgressView("Fetching your vibe...")
                    }
                }
            }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel.shared)
}

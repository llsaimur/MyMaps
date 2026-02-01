//
//  OnboardingView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 1/31/26.
//


import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @StateObject var locationManager = LocationManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("📍")
                .font(.system(size: 100))
            Text("Welcome to MyMaps")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Discover the best spots recommended by people you actually trust.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button {
                            locationManager.requestLocationPermission()
                        } label: {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 300, height: 50)
                                .background(Color.blue)
                                .clipShape(Capsule())
                        }
                        .padding(.bottom, 40)
                    }
                    // CLEAN CODE: Listen for the status change here
                    .onChange(of: locationManager.authorizationStatus) { newStatus in
                        if newStatus != .notDetermined && newStatus != nil {
                            // Once they pick 'Allow' or 'Deny', move forward
                            hasCompletedOnboarding = true
                        }
                    }
    }
}

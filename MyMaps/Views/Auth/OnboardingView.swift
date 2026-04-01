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
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.85), Color(red: 0.05, green: 0.05, blue: 0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.15))
                            .frame(width: 110, height: 110)
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 52, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    VStack(spacing: 10) {
                        Text("MyMaps")
                            .font(.system(size: 42, weight: .black))
                            .foregroundStyle(.white)
                            .tracking(-1)

                        Text("Discover the best spots shared\nby people you actually trust.")
                            .font(.system(size: 17))
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                }

                Spacer()

                VStack(spacing: 12) {
                    featurePill(icon: "figure.walk", text: "Explore spots near you")
                    featurePill(icon: "person.2.fill", text: "Follow friends & see their picks")
                    featurePill(icon: "star.fill", text: "Save places to your wishlist")
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 44)

                Button {
                    locationManager.requestLocationPermission()
                } label: {
                    Text("Get Started")
                        .font(.system(size: 17, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.white)
                        .foregroundStyle(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)

                Text("We'll ask for location access to show nearby spots.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 12)
                    .padding(.bottom, 48)
            }
        }
        .onChange(of: locationManager.authorizationStatus) { newStatus in
            if newStatus != .notDetermined && newStatus != nil {
                hasCompletedOnboarding = true
            }
        }
    }

    private func featurePill(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 36, height: 36)
                .background(.white)
                .clipShape(Circle())

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

//
//  SplashView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/28/26.
//

import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.85

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 72))
                    .foregroundStyle(.blue)

                Text("MyMaps")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)

                Text("Discover with people you trust.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    opacity = 1
                    scale = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        isActive = false
                    }
                }
            }
        }
    }
}

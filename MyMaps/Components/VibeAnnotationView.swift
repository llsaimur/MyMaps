//
//  VibeAnnotationView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/1/26.
//


import SwiftUI

struct VibeAnnotationView: View {
    let vibe: VibeType
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: vibe.icon)
                .font(.system(size: 20))
                .padding(8)
                .background(vibe.color)
                .foregroundColor(.white)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 3)
            
            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(vibe.color)
                .frame(width: 10, height: 10)
                .rotationEffect(Angle(degrees: 180))
                .offset(y: -3)
        }
    }
}

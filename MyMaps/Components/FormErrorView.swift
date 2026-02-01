//
//  AuthErrorView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 1/31/26.
//


import SwiftUI

struct FormErrorView: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
            Text(message)
        }
        .font(.caption)
        .foregroundColor(.red)
        .transition(.move(edge: .top).combined(with: .opacity))
        .padding(.top, 8)
    }
}

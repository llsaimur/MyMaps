//
//  MainMapView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 1/31/26.
//


import SwiftUI

struct MainMapView: View {
    let user: User
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Map Experience Coming Soon")
                    .font(.title)
                
                Text("Welcome, \(user.username)!")
                
                Button("Sign Out") {
                    authViewModel.signOut()
                }
                .padding()
                .foregroundColor(.red)
            }
            .navigationTitle("MyMaps")
        }
    }
}
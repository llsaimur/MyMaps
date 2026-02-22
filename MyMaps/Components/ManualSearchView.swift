//
//  ManualSearchView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/1/26.
//

import SwiftUI
import MapKit


struct ManualSearchView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isEnteringManually = false
    @State private var isGeocoding = false
    
    @State private var manualName = ""
    @State private var street = ""
    @State private var city = ""
    @State private var selectedProvince = "ON"
    @State private var postalCode = ""
    
    @State private var showErrorAlert = false
    
    let provinces = ["AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE", "QC", "SK", "YT"]
    
    @State private var mapSelection: CLLocationCoordinate2D?
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            List {
                if mapSelection == nil {
                    Section("Search Results") {
                        if viewModel.searchResults.isEmpty && !viewModel.searchQuery.isEmpty {
                            Text("No results found in Canada").font(.caption).foregroundStyle(.secondary)
                        }
                        
                        ForEach(viewModel.searchResults, id: \.self) { item in
                            Button {
                                selectPlace(
                                    name: item.name ?? "Unknown",
                                    address: item.placemark.title ?? "",
                                    coord: item.placemark.coordinate
                                )
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(item.name ?? "").font(.headline)
                                    Text(item.placemark.title ?? "").font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    
                    Section {
                        if !isEnteringManually {
                            Button { withAnimation { isEnteringManually = true } } label: {
                                Label("Enter Canadian address manually", systemImage: "map.fill")
                            }
                        } else {
                            VStack(spacing: 12) {
                                TextField("Restaurant Name", text: $manualName)
                                    .textFieldStyle(.roundedBorder)
                                
                                TextField("Street Address", text: $street)
                                    .textFieldStyle(.roundedBorder)
                                
                                HStack {
                                    TextField("City", text: $city)
                                        .textFieldStyle(.roundedBorder)
                                    
                                    Picker("Prov", selection: $selectedProvince) {
                                        ForEach(provinces, id: \.self) { prov in
                                            Text(prov).tag(prov)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .labelsHidden()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                                
                                TextField("Postal Code (e.g. A1B 2C3)", text: $postalCode)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.allCharacters)
                                
                                Button(action: performCanadianGeocode) {
                                    HStack {
                                        if isGeocoding { ProgressView().tint(.white).padding(.trailing, 5) }
                                        Text(isGeocoding ? "Locating..." : "Verify on Map")
                                    }
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(isFormValid ? Color.red : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .disabled(!isFormValid || isGeocoding)
                            }
                            .padding(.vertical, 8)
                        }
                    } header: {
                        Text("Manual Entry (Canada)")
                    }
                } else {
                    Section("Confirm & Adjust Pin") {
                        ZStack {
                            Map(position: $cameraPosition, interactionModes: .all) {
                                if let coord = mapSelection {
                                    Marker(manualName, coordinate: coord)
                                }
                            }
                            .frame(height: 300)
                            .cornerRadius(12)
                            
                            Image(systemName: "hand.tap.fill")
                                .foregroundStyle(.white)
                                .padding(8)
                                .background(.black.opacity(0.5))
                                .clipShape(Circle())
                                .offset(x: 120, y: -110)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(manualName).font(.headline)
                            Text("\(street), \(city), \(selectedProvince) \(postalCode)")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        
                        Button {
                            if let coord = mapSelection {
                                selectPlace(name: manualName, address: "\(street), \(city)", coord: coord)
                            }
                        } label: {
                            Text("Confirm Location")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        Button("Go Back & Edit") {
                            withAnimation { mapSelection = nil }
                        }
                        .frame(maxWidth: .infinity)
                        .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Find a Place")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchQuery)
            .onChange(of: viewModel.searchQuery) { _ in viewModel.performSearch() }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Close") { dismiss() } }
            }
        }
    }
    
    private var isFormValid: Bool {
        !manualName.isEmpty && !street.isEmpty && !city.isEmpty && postalCode.count >= 6
    }
    
    private func selectPlace(name: String, address: String, coord: CLLocationCoordinate2D) {
        viewModel.detectedPlace = Place(
            name: name,
            address: address,
            latitude: coord.latitude,
            longitude: coord.longitude
        )
        
        viewModel.searchQuery = ""
        viewModel.searchResults = []
        
        viewModel.validateInput()
        dismiss()
    }
    
    private func performCanadianGeocode() {
        isGeocoding = true
        let fullAddress = "\(street), \(city), \(selectedProvince), \(postalCode), Canada"
        let geocoder = CLGeocoder()
        
        Task {
            do {
                let placemarks = try await geocoder.geocodeAddressString(fullAddress)
                
                if let coordinate = placemarks.first?.location?.coordinate {
                    withAnimation {
                        self.mapSelection = coordinate
                        self.cameraPosition = .region(MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
                        ))
                    }
                }
            } catch {
                print("Geocoding error: \(error.localizedDescription)")
                showErrorAlert = true
            }
            isGeocoding = false
        }
    }
}

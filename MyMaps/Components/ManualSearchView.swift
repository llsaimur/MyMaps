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
    @State private var mapSelection: CLLocationCoordinate2D?
    @State private var cameraPosition: MapCameraPosition = .automatic

    let provinces = ["AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE", "QC", "SK", "YT"]

    var body: some View {
        NavigationStack {
            Group {
                if let coord = mapSelection {
                    confirmationView(coord: coord)
                } else {
                    searchView
                }
            }
            .navigationTitle("Find a Place")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchQuery, prompt: "Search for a place…")
            .onChange(of: viewModel.searchQuery) { _, _ in viewModel.performSearch() }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }


    private var searchView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Search Results
                if !viewModel.searchResults.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(viewModel.searchResults, id: \.self) { item in
                            Button {
                                selectPlace(
                                    name: item.name ?? "Unknown",
                                    address: item.placemark.title ?? "",
                                    coord: item.placemark.coordinate
                                )
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.red)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.name ?? "")
                                            .font(.subheadline.bold())
                                            .foregroundStyle(.primary)
                                        Text(item.placemark.title ?? "")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)
                            Divider().padding(.leading, 58)
                        }
                    }
                } else if !viewModel.searchQuery.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No results found")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                }

                VStack(spacing: 0) {
                    if !isEnteringManually {
                        Button {
                            withAnimation(.spring(response: 0.3)) { isEnteringManually = true }
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "map.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                                Text("Enter address manually")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)
                    } else {
                        manualEntryForm
                    }
                }
                .padding(.top, viewModel.searchResults.isEmpty && viewModel.searchQuery.isEmpty ? 0 : 8)
            }
        }
    }

    private var manualEntryForm: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Manual Address")
                    .font(.subheadline.bold())
                Spacer()
                Button { withAnimation { isEnteringManually = false } } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            VStack(spacing: 12) {
                inputField("Place Name", text: $manualName, icon: "storefront")
                inputField("Street Address", text: $street, icon: "road.lanes")

                HStack(spacing: 12) {
                    inputField("City", text: $city, icon: "building.2")

                    HStack(spacing: 8) {
                        Image(systemName: "mappin")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        Picker("Province", selection: $selectedProvince) {
                            ForEach(provinces, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                inputField("Postal Code (e.g. A1B 2C3)", text: $postalCode, icon: "number")
                    .autocapitalization(.allCharacters)

                Button(action: performCanadianGeocode) {
                    HStack(spacing: 8) {
                        if isGeocoding { ProgressView().tint(.white) }
                        Text(isGeocoding ? "Locating…" : "Verify on Map")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isFormValid ? Color.blue : Color.gray.opacity(0.4))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!isFormValid || isGeocoding)
            }
            .padding(16)
        }
    }

    private func confirmationView(coord: CLLocationCoordinate2D) -> some View {
        VStack(spacing: 0) {
            Map(position: $cameraPosition, interactionModes: .all) {
                Marker(manualName, coordinate: coord)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 320)

            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.red)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(manualName).font(.subheadline.bold())
                        Text("\(street), \(city), \(selectedProvince)  \(postalCode)")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                Divider()

                Button {
                    selectPlace(name: manualName, address: "\(street), \(city)", coord: coord)
                } label: {
                    Text("Confirm Location")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .padding(16)

                Button("Go Back & Edit") {
                    withAnimation { mapSelection = nil }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 16)
            }
        }
    }

    @ViewBuilder
    private func inputField(_ placeholder: String, text: Binding<String>, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            TextField(placeholder, text: text)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var isFormValid: Bool {
        !manualName.isEmpty && !street.isEmpty && !city.isEmpty && postalCode.count >= 6
    }

    private func selectPlace(name: String, address: String, coord: CLLocationCoordinate2D) {
        viewModel.detectedPlace = Place(name: name, address: address,
                                        latitude: coord.latitude, longitude: coord.longitude)
        viewModel.searchQuery = ""
        viewModel.searchResults = []
        viewModel.validateInput()
        dismiss()
    }

    private func performCanadianGeocode() {
        isGeocoding = true
        let fullAddress = "\(street), \(city), \(selectedProvince), \(postalCode), Canada"
        Task {
            do {
                let placemarks = try await CLGeocoder().geocodeAddressString(fullAddress)
                if let coordinate = placemarks.first?.location?.coordinate {
                    withAnimation {
                        mapSelection = coordinate
                        cameraPosition = .region(MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
                        ))
                    }
                }
            } catch {
                print("Geocoding error: \(error.localizedDescription)")
            }
            isGeocoding = false
        }
    }
}

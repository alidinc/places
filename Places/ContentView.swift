//
//  ContentView.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import SwiftUI
import MapKit
import SwiftData
import CoreLocation

struct ContentView: View {
    
    @AppStorage("tint") private var tint: Tint = .blue
    @Bindable var language: LanguageManager
    @Environment(\.dismiss) private var dismiss
    @Environment(LocationsManager.self) private var locationsManager
    @Environment(HUDState.self) private var hudState: HUDState
    @State private var selectedAnnotation: PointAnnotation?
    @State private var position: MapCameraPosition = .automatic
    @State private var showingMultipleCentered = false
    @State private var isLoadingAnnotations = false
    @Query private var savedAddresses: [Address]
    
    var body: some View {
        ZStack {
            MapView
            UserLocationButton
        }
        .onAppear(perform: load)
        .onChange(of: savedAddresses, { _, _ in  load() })
        .onReceive(NotificationCenter.default.publisher(for: Constants.Notifications.addressesChanged)) { update($0) }
        .onReceive(NotificationCenter.default.publisher(for: Constants.Notifications.editingAddress)) { handleEditing($0) }
        .onReceive(NotificationCenter.default.publisher(for: Constants.Notifications.deletedAddress)) { deletedAddress($0) }
        .animation(.easeInOut, value: showingMultipleCentered)
        .sheet(isPresented: .constant(true)) {
            AddressListView(language: language)
                .sheet(item: $selectedAnnotation, content: { annotation in
                    if let address = savedAddresses.first(where: { $0.id == annotation.id }) {
                        EditAddressView(place: address)
                    }
                })
        }
    }
    
    private var MapView: some View {
        Map(position: $position, selection: $selectedAnnotation) {
            ForEach(savedAddresses) { address in
                if let latitude = address.latitude,
                   let longitude = address.longitude {
                    Marker(coordinate: .init(latitude: latitude, longitude: longitude)) {
                        Group {
                            Image(systemName: address.residentType.icon)
                            Text(address.addressLine1)
                        }
                    }
                    .tint(address.residentType == .mine ? tint.color.gradient : Color.orange.gradient)
                    .tag(PointAnnotation(
                        id: address.id,
                        latitude: latitude,
                        longitude: longitude,
                        name: address.addressLine1,
                        addressOwner: address.residentType
                    ))
                }
            }
            UserAnnotation()
        }
        .ignoresSafeArea()
        .overlay(alignment: .center) {
            if isLoadingAnnotations {
                ProgressView()
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(.rect(cornerRadius: 10))
            }
        }
    }
    
    private var UserLocationButton: some View {
        Button {
            positionMapToUsersLocation()
        } label: {
            Image(systemName: "location.fill")
                .padding(10)
                .background(.regularMaterial)
                .clipShape(.circle)
        }
        .padding(.leading)
        .hSpacing(.leading)
        .vSpacing(.top)
    }
}

extension ContentView {
    
    private func load() {
        loadAnnotations()
        positionAnnotations()
    }
    
    private func update(_ notification: NotificationCenter.Publisher.Output) {
        loadAnnotations()
        positionAnnotations()
        
        if let address = notification.object as? Address {
            hudState.show(title: "Added a new address:\n\(address.fullAddress)", systemImage: "checkmark.circle.fill")
        }
    }
    
    private func handleEditing(_ notification: NotificationCenter.Publisher.Output) {
        showingMultipleCentered = false
        
        if let address = notification.object as? Address {
            handleMap(for: address)
        } else {
            positionAnnotations()
        }
    }
    
    private func deletedAddress(_ notification: NotificationCenter.Publisher.Output) {
        if let address = notification.object as? Address {
            hudState.show(title: "Deleted address: \(address.fullAddress)", systemImage: "trash.fill")
        }
    }
    
    private func positionAnnotations() {
        DispatchQueue.main.async {
            switch self.savedAddresses.count {
            case 0:
                self.positionMapToUsersLocation()
            case 1:
                if let firstAddress = self.savedAddresses.first {
                    self.handleMap(for: firstAddress)
                }
            default:
                self.showingMultipleCentered = true
                self.position = .automatic
            }
        }
    }
    
    @MainActor
    private func loadAnnotations() {
        Task {
            isLoadingAnnotations = true
            for address in savedAddresses {
                if address.latitude == nil || address.longitude == nil {
                    await address.updateCoordinates()
                }
            }
            isLoadingAnnotations = false
        }
    }
    
    @MainActor
    private func handleMap(for address: Address) {
        if let latitude = address.latitude,
           let longitude = address.longitude {
            adjustMapPosition(latitude: latitude, longitude: longitude)
        }
    }
    
    @MainActor
    private func positionMapToUsersLocation() {
        if let userLocation = locationsManager.manager.location?.coordinate {
            adjustMapPosition(latitude: userLocation.latitude, longitude: userLocation.longitude)
        }
    }
    
    @MainActor
    private func adjustMapPosition(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let offsetLatitude = latitude - 0.01
        let adjustedCenter = CLLocationCoordinate2D(latitude: offsetLatitude, longitude: longitude)
        
        withAnimation {
            position = .region(
                MKCoordinateRegion(
                    center: adjustedCenter,
                    latitudinalMeters: 2000,
                    longitudinalMeters: 2000
                )
            )
        }
    }
}

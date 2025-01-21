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
    @State private var annotations: [PointAnnotation] = []
    @State private var selectedAnnotation: PointAnnotation?
    @State private var position: MapCameraPosition = .automatic
    @State private var showingMultipleCentered = false
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
            ForEach(annotations, id: \.id) { annotation in
                Marker(coordinate: .init(latitude: annotation.latitude, longitude: annotation.longitude)) {
                    Group {
                        Image(systemName: annotation.addressOwner.icon)
                        Text(annotation.name)
                    }
                }
                .tint(annotation.addressOwner == .mine ? tint.color.gradient : Color.orange.gradient)
                .tag(annotation)
            }
            
            UserAnnotation()
        }
        .ignoresSafeArea()
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
    
    @MainActor
    private func positionAnnotations() {
        switch savedAddresses.count {
        case 0:
            positionMapToUsersLocation()
        case 1:
            if let firstAddress = savedAddresses.first {
                handleMap(for: firstAddress)
            }
        default:
            showingMultipleCentered = true
            position = .automatic
        }
    }
    
    private func loadAnnotations() {
        annotations.removeAll()
        for address in savedAddresses {
            address.createAnnotation { annotation in
                if let annotation {
                    annotations.append(annotation)
                }
            }
        }
    }
    
    private func handleMap(for address: Address) {
        address.createAnnotation { annotation in
            if let coordinate = annotation?.coordinate {
                adjustMapPosition(latitude: coordinate.latitude, longitude: coordinate.longitude)
            } else {
                position = .automatic
            }
        }
    }
    
    private func positionMapToUsersLocation() {
        if let userLocation = locationsManager.manager.location?.coordinate {
            adjustMapPosition(latitude: userLocation.latitude, longitude: userLocation.longitude)
        }
    }
    
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

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
            MainSheetView(language: language)
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
                self.adjustMapPositionForMultiple()
            }
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
                    latitudinalMeters: 3000,
                    longitudinalMeters: 3000
                )
            )
        }
    }

    @MainActor
    private func adjustMapPositionForMultiple() {
        guard !savedAddresses.isEmpty else { return }

        // Get all addresses with valid coordinates
        let validAddresses = savedAddresses.filter { $0.latitude != nil && $0.longitude != nil }
        guard !validAddresses.isEmpty else { return }

        // Calculate bounds
        let coordinates = validAddresses.map { address in
            CLLocationCoordinate2D(
                latitude: address.latitude ?? 0,
                longitude: address.longitude ?? 0
            )
        }

        // Create a map rect that contains all coordinates
        let points = coordinates.map { MKMapPoint($0) }
        let mapRect = points.reduce(MKMapRect.null) { rect, point in
            let pointRect = MKMapRect(origin: point, size: MKMapSize(width: 0, height: 0))
            return rect.isNull ? pointRect : rect.union(pointRect)
        }

        // Add padding to the region
        let padding = 1.2 // 50% padding
        let paddedRect = mapRect.insetBy(
            dx: -mapRect.size.width * (padding - 1) / 2,
            dy: -mapRect.size.height * (padding - 1) / 2
        )

        // Move the center point up by 20%
        let centerPoint = MKMapPoint(x: paddedRect.midX, y: paddedRect.midY)
        let centerCoordinate = centerPoint.coordinate
        let verticalOffset = (paddedRect.size.height / MKMapPointsPerMeterAtLatitude(centerCoordinate.latitude)) * 0.2
        let adjustedCenter = CLLocationCoordinate2D(
            latitude: centerCoordinate.latitude - (verticalOffset / 111000), // Approximate degrees per meter at equator
            longitude: centerCoordinate.longitude
        )

        withAnimation {
            self.position = .region(
                MKCoordinateRegion(center: adjustedCenter, latitudinalMeters: paddedRect.height, longitudinalMeters: paddedRect.width)
            )
        }
    }
}

//
//  AddressViewModel.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import Foundation
import MapKit
import Observation
import CoreLocation

@MainActor
@Observable
class PlacesViewModel {

    var searchQuery: String = "" {
        didSet {
            performSearch()
        }
    }

    var searchResults: [SearchResult] = []
    var isPresentingPlaceTypeView = false
    var selectedSearchResult: SearchResult?
    var isSearching: Bool = false

    private var searchTask: Task<Void, Never>?
    private let geocoder = CLGeocoder()

    func performSearch() {
        // Cancel any existing search task
        searchTask?.cancel()

        // Start a new task
        searchTask = Task { [weak self] in
            // Wait for debounce interval (500 milliseconds)
            try? await Task.sleep(nanoseconds: 500_000_000)

            // Check for cancellation
            guard !Task.isCancelled, let self = self else { return }

            await self.searchAddress(query: self.searchQuery)
        }
    }

    func searchAddress(query: String) async {
        guard !query.isEmpty else {
            self.searchResults = []
            return
        }

        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)

        do {
            let response = try await search.start()
            let mapItems = response.mapItems.prefix(10) // Limit results to 10

            var newSearchResults: [SearchResult] = []

            for mapItem in mapItems {
                let coordinate = mapItem.placemark.coordinate
                let title = mapItem.name ?? "Unknown Place"

                // Perform reverse geocoding
                if let placemark = await reverseGeocode(coordinate: coordinate) {
                    let detailedAddress = formatAddress(from: placemark)
                    // Create SearchResult with placemark
                    let searchResult = SearchResult(
                        coordinate: coordinate,
                        title: title,
                        detailedAddress: detailedAddress,
                        placemark: placemark
                    )
                    newSearchResults.append(searchResult)
                }
            }

            self.searchResults = newSearchResults
            self.isSearching = false
        } catch {
            print("Search error: \(error.localizedDescription)")
            self.searchResults = []
        }
    }

    func reverseGeocode(coordinate: CLLocationCoordinate2D) async -> CLPlacemark? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            return placemarks.first
        } catch {
            print("Reverse geocoding error: \(error.localizedDescription)")
            return nil
        }
    }

    private func formatAddress(from placemark: CLPlacemark) -> String {
        var addressLines: [String] = []

        // First Line: subThoroughfare and thoroughfare
        var firstLineComponents: [String] = []

        if let subThoroughfare = placemark.subThoroughfare {
            firstLineComponents.append(subThoroughfare)
        }

        if let thoroughfare = placemark.thoroughfare {
            firstLineComponents.append(thoroughfare)
        }

        if !firstLineComponents.isEmpty {
            addressLines.append(firstLineComponents.joined(separator: " "))
        }

        // Add other address components
        if let locality = placemark.locality {
            addressLines.append(locality)
        }
        
        if let administrativeArea = placemark.administrativeArea {
            addressLines.append(administrativeArea)
        }

        if let postalCode = placemark.postalCode {
            addressLines.append(postalCode)
        }

        if let country = placemark.country {
            addressLines.append(country)
        }

        return addressLines.joined(separator: ", ")
    }
}

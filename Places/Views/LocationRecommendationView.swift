import SwiftUI
import CoreLocation

struct LocationRecommendationView: View {
    
    @AppStorage("tint") private var tint: Tint = .blue
    @Environment(LocationsManager.self) private var locationsManager
    @Environment(CountryViewModel.self) var viewModel
    
    let onAddressSelected: (CLPlacemark) -> Void
    @Binding var showLocationSearch: Bool

    @State private var recommendedAddress: CLPlacemark?
    @State private var isLoadingRecommendation = false
    
    var body: some View {
        Section {
            if let recommendedAddress {
                HStack {
                    VStack(alignment: .leading) {
                        if isLoadingRecommendation {
                            Text("Finding your location...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            currentLocationButton(for: recommendedAddress)
                        }
                    }
                    .padding(.vertical, 1)

                    Spacer()

                    showLocationSearchButton
                }

            } else {

            }
        } header: {
            Text("Current Location")
        } footer: {
            Text("Tap to use your current location for your new address details below, or search for a new address.")
                .foregroundStyle(.secondary)
        }
        .listRowBackground(StyleManager.shared.listRowBackground)
        .task {
            fetchCurrentLocation()
        }
    }

    private func currentLocationButton(for place: CLPlacemark) -> some View {
        Button {
            onAddressSelected(place)
        } label: {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundStyle(tint.color)
                    .font(.subheadline)

                VStack(alignment: .leading) {
                    Text(place.thoroughfare ?? place.subThoroughfare ?? place.subLocality ?? "")
                        .font(.subheadline)

                    Text("\(place.locality ?? ""), \(place.postalCode ?? "")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
        .contentShape(.rect)
    }

    private var showLocationSearchButton: some View {
        Button {
            HapticsManager.shared.vibrateForSelection()
            showLocationSearch = true
        } label: {
            Image(systemName: "magnifyingglass")
            .foregroundStyle(tint.color)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
    }

    private var getLocationButton: some View {
        Button {
            HapticsManager.shared.vibrateForSelection()
            fetchCurrentLocation()
        } label: {
            Image(systemName: recommendedAddress == nil ? "location.fill" : "plus.circle.fill")
                .imageScale(.large)
        }
        .buttonStyle(.plain)
    }

    private func fetchCurrentLocation() {
        isLoadingRecommendation = true
        Task {
            if let location = await locationsManager.getCurrentLocation() {
                do {
                    let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
                    if let placemark = placemarks.first {
                        await MainActor.run {
                            recommendedAddress = placemark
                            isLoadingRecommendation = false
                        }
                    }
                } catch {
                    print("Geocoding error: \(error)")
                    await MainActor.run { isLoadingRecommendation = false }
                }
            } else {
                await MainActor.run { isLoadingRecommendation = false }
            }
        }
    }
}


import SwiftUI
import CoreLocation

struct LocationRecommendationView: View {
    
    @Environment(LocationsManager.self) private var locationsManager
    @Environment(CountryViewModel.self) var viewModel
    
    let onAddressSelected: (CLPlacemark) -> Void
    
    @State private var recommendedAddress: CLPlacemark?
    @State private var isLoadingRecommendation = false
    
    var body: some View {
        Section {
            HStack {
                VStack(alignment: .leading) {
                    if isLoadingRecommendation {
                        Text("Finding your location...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if let place = recommendedAddress {
                        Text(place.thoroughfare ?? "")
                            .font(.subheadline)
                        Text("\(place.locality ?? ""), \(place.postalCode ?? "")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Use your current location")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 1)
                
                Spacer()
                
                Button {
                    if let place = recommendedAddress {
                        onAddressSelected(place)
                    } else {
                        fetchCurrentLocation()
                    }
                } label: {
                    Image(systemName: recommendedAddress == nil ? "location.fill" : "plus.circle.fill")
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text("Current Location")
        } footer: {
            Text("Tap the plus button to automatically fill in your current address.")
        }
        .listRowBackground(StyleManager.shared.listRowBackground)
        .task {
            fetchCurrentLocation()
        }
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


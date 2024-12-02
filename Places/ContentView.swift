//
//  ContentView.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import SwiftUI
import MapKit
import SwiftData

struct ContentView: View {
    @AppStorage("tint") private var tint: Tint = .blue

    @Bindable var vm: PlacesViewModel
    @Bindable var language: LanguageManager

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Place.startDate, order: .forward) private var savedAddresses: [Place]

    var body: some View {
        NavigationStack {
            VStack {
                // Address Search
                TextField("Search for address", text: $vm.searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .autocorrectionDisabled()

                // Show ProgressView while searching
                if vm.isSearching {
                    ProgressView("Searching for addresses...")
                        .padding()
                } else {
                    // Search Results
                    List(vm.searchResults) { result in
                        Button(action: {
                            vm.selectedSearchResult = result
                            vm.isPresentingPlaceTypeView = true
                            vm.searchQuery = ""
                            vm.searchResults = []
                        }) {
                            VStack(alignment: .leading) {
                                Text(result.title)
                                    .font(.headline)

                                Text(result.detailedAddress ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                // Saved Addresses List
                List(savedAddresses) { address in
                    VStack(alignment: .leading) {
                        Text(address.addressLine)
                            .font(.headline)

                        HStack {
                            Image(systemName: address.placeType.sfSymbolName)
                                .foregroundColor(.blue)
                            Text(address.placeType.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        if address.placeType == .residentialTenancy, let startDate = address.startDate, let endDate = address.endDate {
                            Text("From: \(startDate, style: .date) To: \(endDate, style: .date)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(address.durationString)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()
            }
            .navigationTitle("Places")
            .sheet(isPresented: $vm.isPresentingPlaceTypeView) {
                if let searchResult = vm.selectedSearchResult {
                    PlaceTypeView(searchResult: searchResult) { placeType, startDate, endDate in
                        // Save the Place into SwiftData
                        let newPlace = Place(
                            addressLine: searchResult.detailedAddress ?? "",
                            placeType: placeType,
                            startDate: startDate,
                            endDate: endDate
                        )
                        modelContext.insert(newPlace)
                        // Clear the selected search result
                        vm.selectedSearchResult = nil
                    }
                } else {
                    // Optionally handle the case where selectedSearchResult is nil
                    Text("No place selected")
                }
            }
        }
    }
}

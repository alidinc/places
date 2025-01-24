//
//  LocationSearchView.swift
//  Places
//

import SwiftUI
import MapKit

// Add SearchCompleterDelegate class
class SearchCompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
    var onUpdate: ([MKLocalSearchCompletion]) -> Void

    init(onUpdate: @escaping ([MKLocalSearchCompletion]) -> Void) {
        self.onUpdate = onUpdate
        super.init()
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        onUpdate(completer.results)
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search failed with error: \(error.localizedDescription)")
    }
}

struct LocationSearchView: View {

    @Environment(\.dismiss) private var dismiss
    @AppStorage("tint") private var tint: Tint = .blue

    let onAddressSelected: (CLPlacemark) -> Void

    @State private var focused = false
    @State private var search = ""
    @State private var isSearching = false
    @State private var locationService = LocationLookupService()

    var body: some View {
        NavigationStack {
            VStack {
                CustomSearchBar(text: $search, focused: $focused, placeholder: "Search address") {
                    isSearching = true
                    locationService.performSearch(query: search) {
                        isSearching = false
                    }
                }

                if isSearching {
                    ProgressView("Searching...")
                        .padding()
                } else {
                    resultsList
                }

                Spacer()
            }
            .navigationTitle("Search address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(tint.color)
                }
            }
        }
        .presentationDetents([.medium, .fraction(0.95)])
        .presentationCornerRadius(20)
        .presentationBackground(.regularMaterial)
        .onAppear {
            focused = true
        }
    }

    private var resultsList: some View {
        List(locationService.searchResults, id: \.self) { result in
            Button {
                Task {
                    isSearching = true
                    if let placemark = await locationService.getPlacemark(from: result) {
                        onAddressSelected(placemark)
                        dismiss()
                    }
                    isSearching = false
                }
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.title)
                        .font(.headline)
                    Text(result.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .listRowInsets(.init())
            .listRowBackground(StyleManager.shared.listRowBackground)
        }
        .scrollContentBackground(.hidden)
        .padding(.top, -20)
    }
}

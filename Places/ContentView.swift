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
    @FocusState private var focused: Bool

    @State private var placeToEdit: Place?
    @State private var showAddManual = false

    @Query(sort: \Place.endDate, order: .forward) private var savedAddresses: [Place]

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HeaderView()
                    SavedPlaces
                }

                Shade
            }
            .gradientBackground()
            .safeAreaInset(edge: .bottom) { SearchView(vm: vm, showAddManual: $showAddManual) }
            .toolbar { ToolbarItem(placement: .topBarTrailing) { SettingsButton } }
            .sheet(isPresented: $showAddManual) { AddPlaceManualView() }
            .sheet(item: $placeToEdit) { address in EditPlaceView(place: address) }
            .sheet(item: $vm.selectedSearchResult) { place in
                AddResidentialDatesView(result: place) { place in
                    vm.selectedSearchResult = nil
                    vm.searchQuery = ""
                    vm.searchResults = []
                    focused = false
                }
            }
        }
    }

    private var Shade: some View {
        Color.black
            .opacity(vm.isSearching ? 0.75 : 0)
            .ignoresSafeArea()
    }

    private var SettingsButton: some View {
        NavigationLink {
            SettingsView(language: language)
        } label: {
            Image(systemName: "gearshape.fill")
        }
        .tint(tint.color)
    }

    private var SavedPlaces: some View {
        List {
            ForEach(savedAddresses) { address in
                PlaceRow(place: address)
                    .swipeActions(allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            delete(address: address)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .tint(.red)

                        Button {
                            placeToEdit = address
                        } label: {
                            Image(systemName: "pencil")
                        }
                        .tint(.orange)
                    }
            }
            .listRowInsets(.init(top: 14, leading: 14, bottom: 14, trailing: 14))
            .listRowBackground(Material.ultraThinMaterial)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .clipShape(.rect(cornerRadius: 12))
    }

    private func delete(address: Place) {
        modelContext.delete(address)
        try? modelContext.save()
    }
}

extension Material: @retroactive View {}

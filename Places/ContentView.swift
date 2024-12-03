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
    @State private var isPresentingAddManualAddress = false
    @Query(sort: \Place.endDate, order: .forward) private var savedAddresses: [Place]

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HeaderView()
                    SavedPlaces
                }

                Color.black
                    .opacity(vm.isSearching ? 0.75 : 0)
                    .ignoresSafeArea()
            }
            .gradientBackground()
            .ignoresSafeArea(edges: .bottom)
            .safeAreaInset(edge: .bottom) {
                SearchView(vm: vm, showAddManual: $isPresentingAddManualAddress)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView(language: language)
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .tint(tint.color)
                }
            }
            .sheet(isPresented: $isPresentingAddManualAddress) { AddPlaceManualView() }
            .sheet(isPresented: $vm.isPresentingPlaceTypeView) {
                if let searchResult = vm.selectedSearchResult {
                    AddPlaceView(searchResult: searchResult) { place in
                        modelContext.insert(place)
                        vm.selectedSearchResult = nil
                    }
                } else {
                    Text("No place selected")
                }
            }
        }
    }

    private var SearchTextField: some View {
        HStack(spacing: 10) {
            TextField("Search for address", text: $vm.searchQuery)
                .textFieldStyle(.plain)
                .padding()
                .padding(.trailing, 40)
                .focused($focused)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 20))
                .autocorrectionDisabled()
                .showClearButton($vm.searchQuery, action: { vm.searchQuery = "" })

            Button {
                isPresentingAddManualAddress = true
            } label: {
                Image(systemName: "plus")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(tint.color.gradient)
            }
        }
        .padding()
    }

    private var SavedPlaces: some View {
        List {
            ForEach(savedAddresses) { address in
                PlaceRow(address: address)
            }
            .onDelete(perform: deleteAddress(at:))
            .listRowInsets(.init(top: 14, leading: 14, bottom: 14, trailing: 14))
            .listRowBackground(Color(.secondarySystemBackground))
        }
        .scrollContentBackground(.hidden)
    }

    private func deleteAddress(at offsets: IndexSet) {
        for index in offsets {
            let address = savedAddresses[index]
            modelContext.delete(address)
            try? modelContext.save()
        }
    }
}

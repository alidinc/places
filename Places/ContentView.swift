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

    @State private var showAddManual = false


    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HeaderView()
                    SavedPlacesView()
                }

                Shade
            }
            .gradientBackground()
            .safeAreaInset(edge: .bottom) { SearchView(vm: vm, showAddManual: $showAddManual) }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SettingsButton
                }
            }
            .sheet(isPresented: $showAddManual) { AddPlaceManualView() }
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
            .opacity(vm.searchResults.count >= 1 ? 0.75 : 0)
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
}

extension Material: @retroactive View {}

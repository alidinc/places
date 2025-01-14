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
    @Bindable var vm: AddressLookUpViewModel
    @Bindable var language: LanguageManager
   
    @Environment(\.modelContext) private var modelContext
    @State private var focused = false
    @State private var showAddManual = false


    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 16) {
                    Header
                    AddressListView()
                }
                
                Shade
            }
            .gradientBackground()
            .safeAreaInset(edge: .bottom) {
                AddressSearchView(vm: vm, showAddManual: $showAddManual, isFocused: $focused)
            }
            .sheet(isPresented: $showAddManual) { AddPlaceManualView() }
            .sheet(item: $vm.selectedSearchResult) { place in
                AddAddressView(result: place) { place in
                    vm.selectedSearchResult = nil
                    vm.searchQuery = ""
                    vm.searchResults = []
                    focused = false
                }
            }
        }
    }
    
    private var Header: some View {
        HStack {
            Spacer()
            
            SettingsButton
        }
        .padding(.horizontal, 20)
    }

    private var Shade: some View {
        Color.black
            .animation(.smooth, value: vm.searchResults)
            .opacity(vm.searchResults.count >= 1 ? 0.75 : 0)
            .ignoresSafeArea()
            .onTapGesture {
                vm.searchQuery = ""
                vm.searchResults = []
                focused = false
            }
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

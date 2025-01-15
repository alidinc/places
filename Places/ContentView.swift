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
    @Bindable var language: LanguageManager
   
    @Environment(\.modelContext) private var modelContext
    @State private var focused = false
    @State private var showAddAddress = false


    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Header
                HeaderView()
                AddressListView()
            }
            .gradientBackground()
            .sheet(isPresented: $showAddAddress) { AddAddressView() }
        }
    }
    
    private var Header: some View {
        HStack {
            Button {
                showAddAddress = true
            } label: {
                Image(systemName: "plus")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(tint.color.gradient)
            }
            
            Spacer()
            
            SettingsButton
        }
        .padding(.horizontal, 20)
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

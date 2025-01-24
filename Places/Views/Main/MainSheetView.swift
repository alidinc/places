//
//  AddressListView.swift
//  Places
//
//  Created by alidinc on 12/12/2024.
//

import SwiftData
import SwiftUI
import Contacts

struct MainSheetView: View {
    
    @AppStorage("current") private var currentAddressId = ""
    @AppStorage("tint") private var tint: Tint = .blue
    @Bindable var language: LanguageManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var scheme
    @Environment(CountryViewModel.self) private var countryVm
    @Environment(HUDState.self) private var hudState: HUDState
    @FocusState private var focused: Bool
   
    @State private var placeToDelete: Address?
    @State private var showDeleteAlert = false
    @State private var showLastThreeYears = false
    @State private var expandedSections: Set<String> = []
    @State private var searchText = ""
    @State private var showingCopyAlert = false
    @State private var selectedAddressOwnerType: ResidentType = .mine
    
    @State private var showAddAddress = false
    @State private var addressToEdit: Address?
    @State private var showChecklist = false
    @State private var showSettings = false
    @State private var checklistAddress: Address?
    @State private var currentDetent: PresentationDetent = .fraction(0.35)
    @Query private var savedAddresses: [Address]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    addressTypePicker
                    Spacer()
                    HStack(spacing: 16) {
                        addNewAddressButton
                        settingsButton
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal)
                
                CustomSearchBar(text: $searchText, placeholder: "Search address") { }

                listView
            }
            .onAppear(perform: handleExpansionForCurrentAddress)
            .sheet(isPresented: $showAddAddress) { AddAddressView() }
            .sheet(item: $addressToEdit) { EditAddressView(place: $0) }
            .sheet(isPresented: $showSettings) { SettingsView(language: language) }
            .customAlert(
                isPresented: $showDeleteAlert,
                config: .init(
                    title: "Are you sure to delete this address?",
                    subtitle: LocalizedStringResource(stringLiteral: placeToDelete?.fullAddress ?? ""),
                    primaryActions: [ .init(title: "Delete", action: deleteSelectedPlace) ],
                    hasCancel: true,
                    cancelAction: { showDeleteAlert = false }
                )
            )
        }
        .interactiveDismissDisabled()
        .presentationDetents([.fraction(0.35), .medium, .fraction(0.95)], selection: $currentDetent)
        .presentationBackground(.thinMaterial)
        .presentationBackgroundInteraction(.enabled)
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(20)
        .onChange(of: currentDetent) { oldValue, newValue in
            if oldValue != newValue {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }
    
    // MARK: - Views
    
    private var addNewAddressButton: some View {
        Button {
            showAddAddress = true
        } label: {
            Image(systemName: "plus")
        }
        .font(.title3.weight(.bold))
        .foregroundStyle(tint.color.gradient)
    }

    private var settingsButton: some View {
        Button {
            showSettings = true
        } label: {
            Image(systemName: "gearshape.fill")
        }
        .font(.title3.weight(.semibold))
        .tint(tint.color)
    }

    
    private var addressTypePicker: some View {
        Menu {
            ForEach(ResidentType.allCases, id: \.self) { type in
                Button {
                    selectedAddressOwnerType = type
                } label: {
                    Label(type.rawValue, systemImage: type.icon)
                }
                .tag(type)
            }
        } label: {
            HStack {
                Image(systemName: selectedAddressOwnerType.icon)
                    .font(.subheadline.weight(.bold))
                
                HStack(spacing: 3) {
                    Text(selectedAddressOwnerType.rawValue)
                        .font(.title3.weight(.semibold))
                    Image(systemName: "chevron.down")
                        .font(.subheadline.weight(.bold))
                }
            }
            .foregroundStyle(tint.color)
        }
    }

    @ViewBuilder
    private var listView: some View {
        if !groupedAddresses.isEmpty {
            List {
                ForEach(sortedCountries, id: \.self) { country in
                    DisclosureGroup(isExpanded: isExpandedBinding(for: country)) {
                        ForEach(groupedAddresses[country] ?? []) { address in
                            Button {
                                addressToEdit = address
                            } label: {
                                AddressRow(place: address)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                deleteButton(for: address)
                                shareButton(for: address)
                                NavigationButton(address: address)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                clipboardButton(for: address)
                            }
                        }
                    } label: {
                        sectionHeader(for: country)
                    }
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 12))
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(StyleManager.shared.listRowSeparator)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        } else {
            ContentUnavailableView(
                "Address Book is Empty",
                systemImage: "book",
                description: Text(selectedAddressOwnerType == .mine ? "Add your own addresses to get started." : "Add other addresses to get started.")
            )
            .scaleEffect(0.75)
        }
    }
    
    // MARK: - Buttons
    
    private func shareButton(for address: Address) -> some View {
        ShareLink(item: address.fullAddress) {
            Image(systemName: "square.and.arrow.up.fill")
        }
        .tint(.indigo)
    }
    
    private func clipboardButton(for address: Address) -> some View {
        Button {
            UIPasteboard.general.string = address.fullAddress
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            hudState.show(title: "Copied to clipboard", systemImage: "clipboard.fill")
        } label: {
            Image(systemName: "document.on.clipboard.fill")
        }
        .tint(.orange)
    }
    
    private func deleteButton(for address: Address) -> some View {
        Button {
            placeToDelete = address
            showDeleteAlert = true
        } label: {
            Image(systemName: "trash")
        }
        .tint(.red)
    }
    
    // MARK: - Section Header
    
    private func sectionHeader(for country: String) -> some View {
        HStack {
            if let flag = countryVm.countryFlags.first(where: { $0.name.lowercased() == country.lowercased() })?.unicodeFlag {
                Text(flag)
            }
            
            Text(country.isEmpty ? "Unknown Country" : country)
                .font(.headline)
                .foregroundStyle(.primary.opacity(0.75))
        }
        .padding(.horizontal)
    }
    
    // MARK: - Grouped Addresses
    
    private var groupedAddresses: [String: [Address]] {
        let allAddresses = savedAddresses
        let filteredAddresses = allAddresses.filter { address in
            let matchesType = selectedAddressOwnerType == .mine ? address.residentType == .mine : address.residentType == .friend
            let matchesSearch = searchText.isEmpty ||
            address.fullAddress.localizedCaseInsensitiveContains(searchText)
            return matchesType && matchesSearch
        }
        
        let sortedAddresses = filteredAddresses.sorted { first, second in
            if first.id == currentAddressId { return true }
            if second.id == currentAddressId { return false }
            return (first.startDate ?? .distantPast) > (second.startDate ?? .distantPast)
        }
        
        return Dictionary(grouping: sortedAddresses) { $0.country.name.isEmpty ? "Other" : $0.country.name }
    }
    
    private var sortedCountries: [String] {
        let allAddresses = groupedAddresses
        guard !allAddresses.isEmpty else { return [] }
        
        let countries = Array(allAddresses.keys)
        return countries.sorted { firstCountry, secondCountry in
            let firstAddresses = allAddresses[firstCountry] ?? []
            let secondAddresses = allAddresses[secondCountry] ?? []
            
            // Check if either country contains the current address
            let firstHasCurrent = firstAddresses.contains { $0.id == currentAddressId }
            let secondHasCurrent = secondAddresses.contains { $0.id == currentAddressId }
            
            // If one country has the current address, it should come first
            if firstHasCurrent && !secondHasCurrent { return true }
            if !firstHasCurrent && secondHasCurrent { return false }
            
            // If neither or both have current address, sort alphabetically
            return firstCountry < secondCountry
        }
    }
    
    // MARK: - Helper Methods and Types
    
    @MainActor
    private func handleExpansionForCurrentAddress() {
        for country in sortedCountries {
            if (groupedAddresses[country] ?? []).contains(where: { $0.id == currentAddressId }) {
                expandedSections.insert(country)
            }
        }
    }
    
    @MainActor
    private func isExpandedBinding(for country: String) -> Binding<Bool> {
        Binding(
            get: { expandedSections.contains(country) },
            set: { isExpanded in
                if isExpanded {
                    expandedSections.insert(country)
                } else {
                    expandedSections.remove(country)
                }
            }
        )
    }
    
    private func deleteSelectedPlace() {
        guard let placeToDelete else { return }
        modelContext.delete(placeToDelete)
        try? modelContext.save()
        showDeleteAlert = false
        NotificationCenter.default.post(name: Constants.Notifications.deletedAddress, object: placeToDelete)
    }
}

//
//  AddressListView.swift
//  Places
//
//  Created by alidinc on 12/12/2024.
//

import SwiftData
import SwiftUI

struct AddressListView: View {
    
    @AppStorage("tint") private var tint: Tint = .blue
    @Environment(\.modelContext) private var modelContext
    @Environment(CountryViewModel.self) private var countryVm
    @Environment(\.colorScheme) private var scheme
    @State private var placeToEdit: Address?
    @State private var placeToDelete: Address?
    @State private var showDeleteAlert = false
    @State private var showLastThreeYears = false

    @Query private var savedAddresses: [Address]
    @State private var expandedSections: Set<String> = []

    var body: some View {
        Group {
            showingLast3YearsButton
            listView
        }
        .sheet(item: $placeToEdit) { EditAddressView(place: $0) }
        .overlay(alignment: .center, content: {
            if savedAddresses.isEmpty {
                unavailableView
            }
        })
        .customAlert(
            isPresented: $showDeleteAlert,
            config: .init(
                title: "Are you sure to delete this address?",
                subtitle: LocalizedStringResource(stringLiteral: placeToDelete?.fullAddress ?? ""),
                primaryActions: [
                    .init(title: "Delete", action: deleteSelectedPlace)
                ],
                hasCancel: true,
                cancelAction: { showDeleteAlert = false }
            )
        )
    }
    
    private var showingLast3YearsButton: some View {
        HStack {
            Spacer()
            Button {
                withAnimation {
                    showLastThreeYears.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: showLastThreeYears ? "calendar.badge.checkmark" : "calendar")
                    Text(showLastThreeYears ? "Showing last 3 years" : "Showing Recent")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: .capsule)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(tint.color)
            }
           
        }
        .padding(.horizontal)
    }

    // MARK: - Views

    private var unavailableView: some View {
        ContentUnavailableView(
            "Add a new address",
            systemImage: "pin.fill",
            description: Text("Don't have any addresses yet.")
        )
        .padding(.bottom, 100)
        .ignoresSafeArea()
    }
    
    private var listView: some View {
        List {
            ForEach(sortedCountries, id: \.self) { country in
                DisclosureGroup(
                    isExpanded: isExpandedBinding(for: country)
                ) {
                    ForEach(groupedAddresses[country] ?? []) { address in
                        AddressRow(place: address)
                            .swipeActions(allowsFullSwipe: false) {
                                deleteButton(for: address)
                                editButton(for: address)
                            }
                    }
                } label: {
                    sectionHeader(for: country)
                }
            }
            .listRowInsets(.init(top: 2, leading: 0, bottom: 0, trailing: 12))
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
        .padding()
        .onAppear {
            // Initially expand sections with current addresses
            for country in sortedCountries {
                if (groupedAddresses[country] ?? []).contains(where: { $0.isCurrent }) {
                    expandedSections.insert(country)
                }
            }
        }
    }


    // MARK: - Buttons

    private func deleteButton(for address: Address) -> some View {
        Button {
            placeToDelete = address
            showDeleteAlert = true
        } label: {
            Image(systemName: "trash")
        }
        .tint(.red)
    }

    private func editButton(for address: Address) -> some View {
        Button {
            placeToEdit = address
        } label: {
            Image(systemName: "pencil")
        }
        .tint(.orange)
    }
    
    // MARK: - Section Header

    private func sectionHeader(for country: String) -> some View {
        HStack {
            if let flag = countryVm.countryFlags.first(where: { $0.name?.lowercased() == country.lowercased() }) {
                Text(flag.unicodeFlag ?? "")
            }

            Text(country.isEmpty ? "Unknown Country" : country)
                .font(.headline)
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 4)
    }
    
    // MARK: - Grouped Addresses
    
    private var groupedAddresses: [String: [Address]] {
            let filteredAddresses = showLastThreeYears ?
                savedAddresses.filter { address in
                    let threeYearsAgo = Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date()
                    return address.endDate ?? .now > threeYearsAgo
                } : savedAddresses
            
            // Create sorted addresses with current ones first, then by start date
            let sortedAddresses = filteredAddresses.sorted { first, second in
                if first.isCurrent != second.isCurrent {
                    return first.isCurrent
                }
                return (first.startDate ?? .distantPast) > (second.startDate ?? .distantPast)
            }
            
            return Dictionary(grouping: sortedAddresses) { address in
                address.country
            }
        }
        
        // Add computed property for sorted countries
        private var sortedCountries: [String] {
            let countries = Array(groupedAddresses.keys)
            return countries.sorted { firstCountry, secondCountry in
                let firstHasCurrent = (groupedAddresses[firstCountry] ?? []).contains { $0.isCurrent }
                let secondHasCurrent = (groupedAddresses[secondCountry] ?? []).contains { $0.isCurrent }
                
                if firstHasCurrent != secondHasCurrent {
                    return firstHasCurrent
                }
                return firstCountry < secondCountry
            }
        }
    
    
    // Add helper function for expanded binding
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



    // MARK: - Delete Address

    private func deleteSelectedPlace() {
        guard let placeToDelete else { return }
        withAnimation {
            modelContext.delete(placeToDelete)
            try? modelContext.save()
        }
        showDeleteAlert = false
    }
}

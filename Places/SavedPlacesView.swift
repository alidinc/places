//
//  SavedPlacesView.swift
//  Places
//
//  Created by alidinc on 12/12/2024.
//

import SwiftData
import SwiftUI

struct SavedPlacesView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(CountryViewModel.self) private var countryVm
    @State private var placeToEdit: Place?
    @State private var placeToDelete: Place?
    @State private var showDeleteAlert = false

    @Query(sort: \Place.endDate, order: .forward) private var savedAddresses: [Place]

    var body: some View {
        Group {
            if savedAddresses.isEmpty {
                unavailableView
            } else {
                listView
            }
        }
        .sheet(item: $placeToEdit) { EditPlaceView(place: $0) }
        .customAlert(
            isPresented: $showDeleteAlert,
            config: .init(
                title: "Are45",
                subtitle: LocalizedStringResource(stringLiteral: placeToDelete?.fullAddress ?? ""),
                primaryActions: [
                    .init(title: "Delete", action: deleteSelectedPlace)
                ],
                hasCancel: true,
                cancelAction: { showDeleteAlert = false }
            )
        )
    }

    // MARK: - Views

    private var unavailableView: some View {
        ContentUnavailableView(
            "Add a new address",
            systemImage: "pin.fill",
            description: Text("Don't have any addresses yet.")
        )
        .padding()
    }

    private var listView: some View {
        List {
            ForEach(groupedAddresses.keys.sorted(by: { $0?.country ?? "" < $1?.country ?? "" }), id: \.self) { country in
                Section {
                    ForEach(groupedAddresses[country] ?? []) { address in
                        PlaceRow(place: address)
                            .swipeActions(allowsFullSwipe: false) {
                                deleteButton(for: address)
                                editButton(for: address)
                            }
                    }
                } header: {
                    if let country {
                        sectionHeader(for: country)
                    }
                }
            }
            .listRowInsets(.init())
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
        .clipShape(.rect(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.bottom)
    }

    // MARK: - Buttons

    private func deleteButton(for address: Place) -> some View {
        Button {
            placeToDelete = address
            showDeleteAlert = true
        } label: {
            Image(systemName: "trash")
        }
        .tint(.red)
    }

    private func editButton(for address: Place) -> some View {
        Button {
            placeToEdit = address
        } label: {
            Image(systemName: "pencil")
        }
        .tint(.orange)
    }

    // MARK: - Section Header

    private func sectionHeader(for country: Country) -> some View {
        HStack {
            if let flag = countryVm.countryFlags.first(where: { $0.name?.lowercased() == country.country.lowercased() }) {
                Text(flag.unicodeFlag ?? "")
            }

            Text(country.country.isEmpty ? "Unknown Country" : country.country)
                .font(.headline)
        }
        .padding(.leading)
    }

    // MARK: - Grouped Addresses

    private var groupedAddresses: [Country?: [Place]] {
        Dictionary(grouping: savedAddresses, by: { $0.country })
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

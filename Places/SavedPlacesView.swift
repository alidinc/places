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
        List {





            
            ForEach(groupedAddresses.keys.sorted(), id: \.self) { country in
                Section {
                    ForEach(groupedAddresses[country] ?? []) { address in
                        PlaceRow(place: address)
                            .swipeActions(allowsFullSwipe: false) {
                                Button {
                                    placeToDelete = address
                                    showDeleteAlert = true
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
                } header: {
                    SectionHeader(for: country)
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
        .overlay(alignment: .center) {
            if savedAddresses.isEmpty {
                ContentUnavailableView("Add a new address",
                                       systemImage: "pin.fill",
                                       description: Text("Don't have any addresses yet"))
                    .padding()
            }
        }
        .sheet(item: $placeToEdit) { EditPlaceView(place: $0) }
        .customAlert(
            isPresented: $showDeleteAlert,
            config: .init(
                title: "Would you like to delete this address?",
                subtitle: "You won't be able to revert this action.",
                primaryActions: [.init(
                    title: "Delete",
                    action: {
                        if let placeToDelete {
                            delete(address: placeToDelete)
                        }
                    })],
                hasCancel: true,
                cancelAction: { showDeleteAlert = false }
            )
        )
    }

    private func SectionHeader(for country: String) -> some View {
        HStack {
            if let countryFlag = countryVm.countryFlags.first(where: { ($0.name ?? "").lowercased() == country.lowercased() }) {
                Text(countryFlag.unicodeFlag ?? "")
            }

            Text(country)
                .font(.headline)
        }
        .padding(.leading)
    }

    private var groupedAddresses: [String: [Place]] {
        Dictionary(grouping: savedAddresses, by: { $0.country })
    }

    private func delete(address: Place) {
        withAnimation {
            modelContext.delete(address)
            try? modelContext.save()
        }
    }
}

#Preview {
    SavedPlacesView()
}

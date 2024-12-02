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

    @State private var selectedStartDate = Date()
    @State private var selectedEndDate = Date()
    @State private var selectedAddress: String = ""

    @Query(sort: \Place.startDate, order: .forward) private var savedAddresses: [Place]

    var body: some View {
        NavigationStack {
            VStack {
                // Address Search
                TextField("Search for address", text: $vm.searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onSubmit {
                        vm.searchAddress(query: vm.searchQuery)
                    }

                List(vm.searchResults, id: \.self) { item in
                    Button(action: {
                        selectedAddress = item.placemark.title ?? "Unknown Address"
                    }) {
                        Text(item.placemark.title ?? "Unknown Address")
                    }
                }

                // Date Pickers
                VStack {
                    DatePicker("Start Date", selection: $selectedStartDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $selectedEndDate, displayedComponents: .date)
                }
                .padding(40)


                // Add Address Button
                Button(
                    action: {
                        if !selectedAddress.isEmpty {
                            let newAddress = Place(
                                addressLine: selectedAddress,
                                startDate: selectedStartDate,
                                endDate: selectedEndDate
                            )
                        modelContext.insert(newAddress)
                        selectedAddress = ""
                    }
                }) {
                    Text("Save Address")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(selectedAddress.isEmpty)

                // Saved Addresses List
                List(savedAddresses) { address in
                    VStack(alignment: .leading) {
                        Text(address.addressLine)
                            .font(.headline)
                        Text("From: \(address.startDate, style: .date) To: \(address.endDate, style: .date)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()
            }
            .navigationTitle("Places")
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
        }
    }
}

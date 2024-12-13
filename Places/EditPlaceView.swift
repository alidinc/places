//
//  EditPlaceView.swift
//  Places
//
//  Created by alidinc on 11/12/2024.
//

import SwiftUI

struct EditPlaceView: View {

    @AppStorage("tint") private var tint: Tint = .blue
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var place: Place

    // Address fields
    @State private var apartmentNumber = ""
    @State private var name = ""
    @State private var addressLine1 = ""
    @State private var addressLine2 = ""
    @State private var city = ""
    @State private var postcode = ""
    @State private var country: Country?
    @State private var startDate = Date()
    @State private var endDate = Date()

    // Country and City Picker
    @Environment(CountryViewModel.self) var viewModel

    var body: some View {
        NavigationStack {
            Form {
                // Address Section
                Section(header: Text("Address Details")) {
                    if let name = place.name, name.isEmpty {
                        TextField("Address Line 1", text: $addressLine1)
                        TextField("Address Line 2", text: $addressLine2)
                    } else {
                        TextField("Address Line 1", text: $name)
                    }
                   
                    TextField("Apartment/House Number", text: $apartmentNumber)
                        .keyboardType(.decimalPad)

                    Picker("Country", selection: $country) {
                        Text("Select a Country").tag(nil as Country?)
                        ForEach(viewModel.countries, id: \.hashValue) { country in
                            Text(country.country).tag(country as Country?)
                        }
                    }

                    if let country {
                        Picker("City", selection: $city) {
                            Text("Select a City").tag("") // Placeholder for no selection
                            ForEach(country.cities.sorted(by: { $0 < $1 }), id: \.self) { cityName in
                                Text(cityName).tag(cityName)
                            }
                        }
                    }

                    TextField("Postal Code", text: $postcode)
                }

                Section(header: Text("Dates")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Edit Address")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                 loadPlaceDetails()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(startDate > endDate)
                    .foregroundStyle(tint.color.gradient)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.fraction(0.72)])
    }

    @MainActor
    private func loadPlaceDetails() {
        name = place.name ?? ""
        addressLine1 = place.addressLine1
        addressLine2 = place.addressLine2
        apartmentNumber = place.apartmentNumber
        city = place.city
        postcode = place.postcode
        country = place.country
        startDate = place.startDate ?? .now
        endDate = place.endDate ?? .now
        
        if let country, let city = country.cities.first(where: { $0.lowercased() == place.city.lowercased() }) {
            self.city = city
        }
    }

    private func saveChanges() {
        place.addressLine1 = addressLine1
        place.addressLine2 = addressLine2
        place.apartmentNumber = apartmentNumber
        place.city = city
        place.country = country
        place.postcode = postcode
        place.startDate = startDate
        place.endDate = endDate

        dismiss()
    }
}

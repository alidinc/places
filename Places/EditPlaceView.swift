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
    @State private var country = ""
    @State private var startDate = Date()
    @State private var endDate = Date()

    // Country and City Picker
    @Environment(CountryViewModel.self) var viewModel
    @State private var selectedCountry: Country?
    @State private var selectedCity: String = ""

    var body: some View {
        NavigationStack {
            Form {
                // Address Section
                Section(header: Text("Address Details")) {
                    TextField("Address Line 1", text: $addressLine1)
                    TextField("Address Line 2", text: $addressLine2)
                    TextField("Apartment/House Number", text: $apartmentNumber)
                        .keyboardType(.decimalPad)

                    Picker("Country", selection: $selectedCountry) {
                        Text("Select a Country").tag("Select")
                        ForEach(viewModel.countries, id: \.hashValue) { country in
                            Text(country.country).tag(country)
                        }
                    }
                    .onChange(of: selectedCountry) { _, newValue in
                        selectedCity = ""
                        self.country = newValue?.country ?? ""
                    }

                    if let selectedCountry {
                        Picker("City", selection: $selectedCity) {
                            Text("Select a City").tag("Select")
                            ForEach(selectedCountry.cities.sorted(by: { $0 < $1 }), id: \.self) { city in
                                Text(city).tag(city)
                            }
                        }
                        .onChange(of: selectedCity) { _, newValue in
                            self.city = newValue
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

    private func loadPlaceDetails() {
        addressLine1 = place.addressLine1
        addressLine2 = place.addressLine2
        apartmentNumber = place.apartmentNumber
        city = place.city
        postcode = place.postcode
        country = place.country
        startDate = place.startDate ?? .now
        endDate = place.endDate ?? .now

        // Preselect country and city if available
        if let existingCountry = viewModel.countries.first(where: { $0.country.lowercased() == country.lowercased() }) {
            selectedCountry = existingCountry

            if let existingCity = existingCountry.cities.first(where: { $0.lowercased() == city.lowercased() }) {
                selectedCity = existingCity
            }
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

//
//  EditAddressView.swift
//  Places
//
//  Created by alidinc on 11/12/2024.
//

import SwiftUI

struct EditAddressView: View {

    @AppStorage("tint") private var tint: Tint = .blue
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var place: Address

    // Address fields
    @State private var apartmentNumber = ""
    @State private var name = ""
    @State private var addressLine1 = ""
    @State private var addressLine2 = ""
    @State private var city = ""
    @State private var sublocality = ""
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

                    Picker(selection: $country) {
                        ForEach(viewModel.countries, id: \.hashValue) { country in
                            Text(country.country).tag(country as Country?)
                        }
                    } label: {
                        Text("Select a Country")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }

                    TextField("City", text: $city)
                
                    TextField("State", text: $sublocality)

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
        
        if let name = place.name {
            self.name = name
        }
       
        addressLine1 = place.addressLine1
        addressLine2 = place.addressLine2
        apartmentNumber = place.apartmentNumber
        postcode = place.postcode
        country = place.country
        
        if let sublocality = place.sublocality {
            self.sublocality = sublocality
        }
        
        startDate = place.startDate ?? .now
        endDate = place.endDate ?? .now

        if let country {
            if country.country.lowercased() == "türkiye" {
                self.city = place.city
            } else {
                self.city = place.locality ?? place.city
            }
        } else {
            self.city = place.city
        }
    }

    private func findCityAsync(cityToFind: String, in country: Country) async {
        // Perform the search in the background
        let citySet = Set(country.cities.map { $0.lowercased() })

        // Perform the search asynchronously
        if citySet.contains(cityToFind.lowercased()) {
            DispatchQueue.main.async {
                // If the city is found in the set, assign it to `city`
                city = cityToFind
            }
        } else {
            DispatchQueue.main.async {
                // If no matching city is found, set city to an empty string
                city = ""
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

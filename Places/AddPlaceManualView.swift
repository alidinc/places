//
//  AddPlaceManualView.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import SwiftUI

struct AddPlaceManualView: View {

    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    // Address fields
    @State private var apartmentNumber = ""
    @State private var addressLine1 = ""
    @State private var addressLine2 = ""
    @State private var city = ""
    @State private var state = ""
    @State private var postalCode = ""
    @State private var country = ""

    // Place type and dates
    @State private var selectedPlaceType: PlaceType = .residential
    @State private var startDate = Date()
    @State private var endDate = Date()

    // Validation
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                // Address Section
                Section(header: Text("Address Details")) {
                    TextField("Address Line 1", text: $addressLine1)
                    TextField("Address Line 2", text: $addressLine2)
                    TextField("Apartment/House Number", text: $apartmentNumber)
                        .keyboardType(.decimalPad)
                    TextField("City", text: $city)
                    TextField("State", text: $state)
                    TextField("Postal Code", text: $postalCode)
                    TextField("Country", text: $country)
                }

                Section(header: Text("Dates")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Address Manually")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePlace()
                    }
                    .disabled(!isFormValid())
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Input"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func isFormValid() -> Bool {
        !addressLine1.isEmpty &&
        !city.isEmpty &&
        !country.isEmpty &&
        (selectedPlaceType == .residential ? startDate <= endDate : true)
    }

    private func savePlace() {
        guard isFormValid() else {
            alertMessage = "Please fill in all required fields."
            showAlert = true
            return
        }

        let place = Place(
            apartmentNumber: apartmentNumber,
            addressLine1: addressLine1,
            addressLine2: addressLine2,
            city: city,
            postcode: postalCode,
            country: country,
            placeType: .residential,
            startDate: startDate,
            endDate: endDate
        )

        modelContext.insert(place)
        dismiss()
    }
}

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
    @State private var selectedPlaceType: PlaceType = .residentialTenancy
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

                // Place Type Section
                Section(header: Text("Place Type")) {
                    Picker("Select Place Type", selection: $selectedPlaceType) {
                        ForEach(PlaceType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Tenancy Dates Section
                if selectedPlaceType == .residentialTenancy {
                    Section(header: Text("Tenancy Dates")) {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    }
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
        // Basic validation: Address Line 1, City, and Country are required
        return !addressLine1.isEmpty && !city.isEmpty && !country.isEmpty && (selectedPlaceType == .residentialTenancy ? startDate <= endDate : true)
    }

    private func savePlace() {
        guard isFormValid() else {
            alertMessage = "Please fill in all required fields."
            showAlert = true
            return
        }

        // Combine address fields into a single address line
        let addressComponents = [addressLine1, addressLine2, city, state, postalCode, country]
        let fullAddress = addressComponents.filter { !$0.isEmpty }.joined(separator: ", ")

        // Create new Place
        let newPlace = Place(
            addressLine: fullAddress,
            apartmentNumber: apartmentNumber,
            placeType: selectedPlaceType,
            startDate: selectedPlaceType == .residentialTenancy ? startDate : nil,
            endDate: selectedPlaceType == .residentialTenancy ? endDate : nil
        )

        // Save to model context
        modelContext.insert(newPlace)
        dismiss()
    }
}

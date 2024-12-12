//
//  EditPlaceView.swift
//  Places
//
//  Created by alidinc on 11/12/2024.
//

import SwiftUI

struct EditPlaceView: View {

    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var place: Place

    var body: some View {
        NavigationStack {
            Form {
                // Address Section
                Section(header: Text("Address Details")) {
                    if place.addressLine1.isEmpty {
                        TextField("Address Line 1", text: Binding(get: {
                            place.name ?? ""
                        }, set: { value in
                            place.name = value
                        }))
                    } else {
                        TextField("Address Line 1", text: $place.addressLine1)
                    }

                    TextField("Address Line 2", text: $place.addressLine2)
                    TextField("Apartment/House Number", text: $place.apartmentNumber)
                        .keyboardType(.decimalPad)
                    TextField("City", text: $place.city)
                    TextField("Postal Code", text: $place.postcode)
                    TextField("Country", text: $place.country)
                }

                Section(header: Text("Dates")) {
                    DatePicker("Start Date", selection: Binding(get: {
                        place.startDate ?? .now
                    }, set: { value in
                        place.startDate = value
                    }), displayedComponents: .date)
                    DatePicker("End Date", selection: Binding(get: {
                        place.endDate ?? .now
                    }, set: { value in
                        place.endDate = value
                    }), displayedComponents: .date)
                }
            }
            .navigationTitle("Edit Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!isFormValid())
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func isFormValid() -> Bool {
        // Basic validation: Address Line 1, City, and Country are required
        // Also if residential, startDate <= endDate
        return !place.addressLine1.isEmpty && !place.city.isEmpty && !place.country.isEmpty &&
        (place.placeType == .residential ? place.startDate ?? .now <= place.endDate ?? .now : true)
    }

    private func saveChanges() {
        guard isFormValid() else {
            return
        }

        dismiss()
    }
}

//
//  AddResidentialDatesView.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import SwiftUI

struct AddResidentialDatesView: View {

    let result: SearchResult
    let onDismiss: (Place) -> Void

    @AppStorage("tint") private var tint: Tint = .blue
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context

    @State private var selectedPlaceType: PlaceType = .residential
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var apartmentNumber = ""
    @State private var currentAddress = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    datePickerSection
                    if !currentAddress { endDatePickerSection }
                    toggleSection
                    textFieldSection
                }
                .padding()
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))

                address

                Spacer()

                saveButton
            }
            .padding()
            .navigationTitle("Add Place")
            .navigationBarTitleDisplayMode(.inline)
            .animation(.smooth, value: currentAddress)
            .animation(.smooth, value: apartmentNumber)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        savePlace()
                    }
                    .font(.headline.weight(.medium))
                    .foregroundStyle(tint.color.gradient)
                    .disabled(startDate > endDate)
                }
            }
        }
        .presentationDetents([.fraction(0.65)])
    }

    @ViewBuilder
    private var address: some View {
        if apartmentNumber.isEmpty {
            Text(result.searchAddress)
                .font(.headline.weight(.semibold))
                .padding(12)
        } else {
            Text("\(apartmentNumber), \(result.searchAddress)")
                .font(.headline.weight(.semibold))
                .padding(12)
        }
    }

    private var datePickerSection: some View {
        HStack {
            Text("Start Date")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Spacer()
            DatePicker("", selection: $startDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
        }
    }

    private var toggleSection: some View {
        HStack {
            Text("Is this your current address?")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Spacer()
            Toggle("", isOn: $currentAddress)
                .labelsHidden()
                .tint(.green)
        }
    }

    private var endDatePickerSection: some View {
        HStack {
            Text("End Date")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Spacer()
            DatePicker("", selection: $endDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
        }
    }

    private var textFieldSection: some View {
        HStack {
            Text("Apartment/House Number")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Spacer()
            TextField("No", text: $apartmentNumber)
                .padding(.trailing, 50)
                .frame(maxWidth: 150)
                .showClearButton($apartmentNumber, action: { apartmentNumber = "" })
        }
    }

    private var saveButton: some View {
        Button(action: savePlace) {
            Text("Save")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(tint.color.gradient, in: .rect(cornerRadius: 12))
                .foregroundStyle(.white)
                .shadow(color: .blue.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .disabled(startDate > endDate)
        .padding(.horizontal)
    }

    private func savePlace() {
        if startDate > endDate { return }

        let name = result.placemark.name ?? ""
        let addressLine1 = result.placemark.thoroughfare ?? ""
        let addressLine2 = result.placemark.subThoroughfare ?? ""
        let city = result.placemark.locality ?? ""
        let country = result.placemark.country ?? ""
        let postcode = result.placemark.postalCode ?? ""

        let place = Place(
            name: name,
            apartmentNumber: apartmentNumber,
            addressLine1: addressLine1,
            addressLine2: addressLine2,
            city: city,
            postcode: postcode,
            country: country,
            placeType: .residential,
            startDate: startDate,
            endDate: endDate
        )

        context.insert(place)
        try? context.save()
        onDismiss(place)
        dismiss()
    }
}

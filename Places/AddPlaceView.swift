//
//  TenancyDatePicker.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import Foundation
import SwiftUI

struct PlaceTypePicker: View {

    @Binding var selectedPlaceType: PlaceType

    var body: some View {
        VStack(spacing: 20) {
            Text("Select Place Type")
                .font(.headline)

            HStack(spacing: 20) {
                ForEach(PlaceType.allCases, id: \.self) { type in
                    Button {
                        selectedPlaceType = type
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: type.icon)
                                .font(.title3)
                                .foregroundStyle(selectedPlaceType == type ? Color.blue : Color.gray)
                            Text(type.rawValue)
                                .font(.subheadline)
                                .foregroundStyle(selectedPlaceType == type ? Color.primary : Color.secondary)
                        }
                        .padding()
                        .frame(width: 120, height: 140)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedPlaceType == type ? Color.blue : Color.gray, lineWidth: 2)
                        )
                    }
                }
            }
        }
        .padding()
    }
}

struct AddPlaceView: View {
    let searchResult: SearchResult
    let onSave: (Place) -> Void
    @Environment(\.dismiss) var dismiss

    @State private var selectedPlaceType: PlaceType = .residentialTenancy
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var apartmentNumber = ""
    @State private var currentAddress = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Address Header
                Text(searchResult.detailedAddress)
                    .font(.title3.weight(.medium))
                    .multilineTextAlignment(.center)
                    .padding()

                // Place Type Picker
                PlaceTypePicker(selectedPlaceType: $selectedPlaceType)

                if selectedPlaceType == .residentialTenancy {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding()

                    // Toggle for end date
                    Toggle("Current Address?", isOn: $currentAddress)
                        .padding(.horizontal)
                        .padding(.bottom, 8)

                    // Only show end date picker if hasEndDate is true
                    if currentAddress {
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding()
                    }

                    VStack {
                        Text("What's your apartment/house number?")
                        TextField("Apartment/House Number", text: $apartmentNumber)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.plain)
                    }
                    .padding()
                }

                Spacer()

                // Save Button
                Button(action: savePlace) {
                    Text("Save")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(selectedPlaceType == .residentialTenancy && currentAddress && startDate > endDate)
            }
            .navigationTitle("Add Place")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func savePlace() {
        // Validation: If we have an end date and startDate is after endDate, return
        if selectedPlaceType == .residentialTenancy && currentAddress && startDate > endDate {
            return
        }

        // Extract addressLine based on place type
        let addressLine: String
        if selectedPlaceType == .placeToVisit {
            // Use city and country
            let city = searchResult.placemark.locality ?? ""
            let country = searchResult.placemark.country ?? ""
            addressLine = [city, country].filter { !$0.isEmpty }.joined(separator: ", ")
        } else {
            // Use detailedAddress
            addressLine = searchResult.detailedAddress
        }

        let finalEndDate = selectedPlaceType == .residentialTenancy && currentAddress ? nil : endDate

        onSave(
            Place(addressLine: addressLine,
                  apartmentNumber: apartmentNumber,
                  placeType: selectedPlaceType,
                  startDate: selectedPlaceType == .residentialTenancy ? startDate : nil,
                  endDate: finalEndDate)
        )
        dismiss()
    }
}

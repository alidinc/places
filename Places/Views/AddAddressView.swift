//
//  AddAddressView.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import SwiftUI

struct AddAddressView: View {

    let result: Location
    let onDismiss: (Address) -> Void

    @AppStorage("tint") private var tint: Tint = .blue
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var scheme
    @Environment(CountryViewModel.self) var viewModel

    @State private var selectedPlaceType: AddressType = .residential
    @State private var startDate = Date()
    @State private var endDate: Date?
    @State private var apartmentNumber = ""
    @State private var currentAddress = false
    @State private var buildingType: BuildingType = .house

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    buildingTypePicker
                    if buildingType != .place {
                        datePickerSection
                        if !currentAddress { endDatePickerSection }
                        toggleSection
                        apartmentNumberSection
                    }
                    
                    address
                }
                .padding()
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))

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
                    .disabled(startDate > endDate ?? .now)
                }
            }
        }
        .presentationDetents([.fraction(0.75)])
    }

    @ViewBuilder
    private var address: some View {
        Group {
            if apartmentNumber.isEmpty {
                Text(result.searchAddress)
            } else {
                if buildingType == .flat {
                    Text("\(buildingType.rawValue) \(apartmentNumber), \(result.searchAddress)")
                       
                } else {
                    Text("\(apartmentNumber), \(result.searchAddress)")
                }
            }
        }
        .font(.headline.weight(.semibold))
        .padding(12)
        .foregroundStyle(tint.color.gradient)
        .hSpacing(.leading)
        .background(scheme == .dark ? .black.opacity(0.75) : .white.opacity(0.75), in: .rect(cornerRadius: 12))
    }
    
    private var buildingTypePicker: some View {
        Picker(selection: $buildingType) {
            ForEach(BuildingType.allCases, id: \.self) {
                Text($0.rawValue).tag($0)
            }
        } label: {
            Text(buildingType.rawValue)
        }
        .pickerStyle(.segmented)
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
        .onChange(of: currentAddress) { oldValue, newValue in
            if newValue {
                endDate = nil
            }
        }
    }

    private var endDatePickerSection: some View {
        HStack {
            Text("End Date")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Spacer()
            DatePicker("", selection: Binding(get: {
                endDate ?? .now
            }, set: { value in
                endDate = value
            }), displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
        }
    }

    private var apartmentNumberSection: some View {
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
        .disabled(startDate > endDate ?? .now)
        .padding(.horizontal)
    }

    private func savePlace() {
        if startDate > endDate ?? .now { return }

        let title = result.title
        let name = result.placemark.name ?? ""
        let addressLine1 = result.placemark.thoroughfare ?? ""
        let addressLine2 = result.placemark.subThoroughfare ?? ""
        let sublocality = result.placemark.subLocality ?? ""
        let locality = result.placemark.locality ?? ""
        let city = result.placemark.administrativeArea ?? ""
        let postcode = result.placemark.postalCode ?? ""
        let country = viewModel.countries.first(where: { $0.country.lowercased() == (result.placemark.country ?? "").lowercased() })

        let place = Address(
            title: title,
            name: name,
            apartmentNumber: apartmentNumber,
            addressLine1: addressLine1,
            addressLine2: addressLine2,
            sublocality: sublocality,
            locality: locality,
            city: city,
            postcode: postcode,
            country: country,
            placeType: .residential,
            buildingType: buildingType,
            startDate: startDate,
            endDate: endDate
        )

        withAnimation {
            context.insert(place)
            try? context.save()
        }
        onDismiss(place)
        dismiss()
    }
}

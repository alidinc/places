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
    @State private var addressFields = AddressFields()

    // Validation
    @State private var showAlert = false
    @State private var alertMessage = ""

    // Country and City Selection
    @Environment(CountryViewModel.self) var viewModel
    @State private var selectedCountry: Country? = nil
    @State private var selectedCity: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Address Details")) {
                    AddressDetailsSection(addressFields: $addressFields)
                }
            }
            .navigationTitle("Add Address Manually")
            .navigationBarTitleDisplayMode(.inline)
            .animation(.smooth, value: addressFields.buildingType)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Input"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePlace()
                    }
                    .disabled(!addressFields.isValid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.fraction(0.65)])
    }

    private func savePlace() {
        guard addressFields.isValid else {
            alertMessage = "Please fill in all required fields."
            showAlert = true
            return
        }
        
        let country = viewModel.countries.first(where: { $0.country.lowercased() == addressFields.country.lowercased() })

        let place = Address(
            apartmentNumber: addressFields.apartmentNumber,
            addressLine1: addressFields.addressLine1,
            addressLine2: addressFields.addressLine2,
            city: addressFields.city,
            postcode: addressFields.postalCode,
            country: country,
            buildingType: addressFields.buildingType,
            startDate: addressFields.startDate,
            endDate: addressFields.endDate,
            isCurrent: addressFields.currentAddress
        )

        modelContext.insert(place)
        try? modelContext.save()
        dismiss()
    }
}


struct AddressDetailsSection: View {
    // MARK: - Properties
    @Binding var addressFields: AddressFields
    @Environment(CountryViewModel.self) var viewModel
    
    // MARK: - Body
    var body: some View {
        Group {
            basicAddressFields
            buildingTypeAndNumber
            locationFields
            statusFields
            dateFields
        }
    }
}

// MARK: - Subviews
private extension AddressDetailsSection {
    var basicAddressFields: some View {
        Group {
            TextField("Address Line 1", text: $addressFields.addressLine1)
            TextField("Address Line 2", text: $addressFields.addressLine2)
            TextField("Postal Code", text: $addressFields.postalCode)
        }
    }
    
    var buildingTypeAndNumber: some View {
        HStack {
            buildingTypeMenu
            Spacer()
            TextField("Apartment/House/Building Number", text: $addressFields.apartmentNumber)
                .keyboardType(.decimalPad)
        }.hSpacing(.leading)
    }
    
    var buildingTypeMenu: some View {
        Menu {
            ForEach(BuildingType.allCases, id: \.self) { type in
                Button {
                    addressFields.buildingType = type
                } label: {
                    Text(type.rawValue)
                }
                .tag(type)
            }
        } label: {
            HStack {
                Text(addressFields.buildingType.rawValue)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
            }
        }
    }
    
    var locationFields: some View {
        Group {
            countryPicker
            if let selectedCountry = addressFields.selectedCountry {
                cityPicker(for: selectedCountry)
            }
        }
    }
    
    var countryPicker: some View {
        Picker(selection: $addressFields.selectedCountry) {
            Text("Select a Country").tag("Select")
            ForEach(viewModel.countries, id: \.hashValue) { country in
                Text(country.country).tag(country)
            }
        } label: {
            pickerLabel("Country")
        }
        .onChange(of: addressFields.selectedCountry) { _, newValue in
            handleCountrySelection(newValue)
        }
    }
    
    func cityPicker(for country: Country) -> some View {
        Picker(selection: $addressFields.selectedCity) {
            Text("Select a City").tag("Select")
            ForEach(country.cities.sorted(by: { $0 < $1 }), id: \.self) { city in
                Text(city).tag(city)
            }
        } label: {
            pickerLabel("City")
        }
        .onChange(of: addressFields.selectedCity) { _, newValue in
            addressFields.city = newValue
        }
    }
    
    var statusFields: some View {
        HStack {
            Text("Is this your current address?")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Spacer()
            Toggle("", isOn: $addressFields.currentAddress)
                .labelsHidden()
                .tint(.green)
        }
    }
    
    var dateFields: some View {
        Group {
            dateField(title: "Start Date", date: $addressFields.startDate)
            dateField(title: "End Date", date: $addressFields.endDate)
        }
    }
}

// MARK: - Helper Views
private extension AddressDetailsSection {
    func pickerLabel(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.secondary)
    }
    
    func dateField(title: String, date: Binding<Date>) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Spacer()
            DatePicker("", selection: date, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
        }
    }
}

// MARK: - Helper Methods
private extension AddressDetailsSection {
    func handleCountrySelection(_ country: Country?) {
        addressFields.selectedCity = ""
        addressFields.country = country?.country ?? ""
    }
}

// MARK: - AddressFields Model
@Observable
class AddressFields {
    // MARK: - Properties
    var apartmentNumber = ""
    var addressLine1 = ""
    var addressLine2 = ""
    var sublocality = ""
    var locality = ""
    var city = ""
    var postalCode = ""
    var country = ""
    var startDate = Date()
    var endDate = Date()
    var currentAddress = false
    var buildingType: BuildingType = .flat
    var selectedCountry: Country? = nil
    var selectedCity: String = ""
    
    // MARK: - Validation
    var isValid: Bool {
        !addressLine1.isEmpty &&
        !city.isEmpty &&
        !country.isEmpty &&
        startDate <= endDate
    }
    
    init() {}
}

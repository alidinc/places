//
//  AddAddressView.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import SwiftUI
import SwiftData

struct AddAddressView: View {

    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    // Address fields
    @State private var addressFields = AddressFields()
    @State private var showAlert = false
    @State private var alertMessage = ""

    @Environment(CountryViewModel.self) var viewModel

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Address Details")) {
                    AddressDetailsSection(addressFields: $addressFields)
                }
            }
            .navigationTitle("Add A New Address")
            .navigationBarTitleDisplayMode(.inline)
            .animation(.smooth, value: addressFields.buildingType)
            .interactiveDismissDisabled()
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
        .presentationDetents([.fraction(0.75), .large])
    }

    private func savePlace() {
        guard addressFields.isValid else {
            alertMessage = "Please fill in all required fields."
            showAlert = true
            return
        }

        let place = Address(
            apartmentNumber: addressFields.apartmentNumber,
            addressLine1: addressFields.addressLine1,
            addressLine2: addressFields.addressLine2,
            sublocality: addressFields.sublocality,
            city: addressFields.city,
            postcode: addressFields.postalCode,
            country: addressFields.country,
            buildingType: addressFields.buildingType,
            startDate: addressFields.startDate,
            endDate: addressFields.endDate,
            isCurrent: addressFields.currentAddress
        )

        modelContext.insert(place)
        try? modelContext.save()
        updateOtherAddressesCurrentStatus(for: place)
        dismiss()
    }
    
    private func updateOtherAddressesCurrentStatus(for place: Address) {
        // Get all addresses except the current one
        if place.isCurrent {
            let descriptor = FetchDescriptor<Address>(sortBy: [SortDescriptor(\Address.endDate)])
            if let addresses = try? modelContext.fetch(descriptor) {
                // Update all other addresses to not be current
                for address in addresses where address.id != place.id {
                    withAnimation {
                        address.isCurrent = false
                    }
                    try? modelContext.save()
                }
            }
        }
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
            TextField("Sublocality", text: $addressFields.sublocality)
            TextField("Postal Code", text: $addressFields.postalCode)
        }
        .autocorrectionDisabled()
    }
    
    var buildingTypeAndNumber: some View {
        HStack {
            buildingTypeMenu
            TextField("Number", text: $addressFields.apartmentNumber)
                .keyboardType(.decimalPad)
                .autocorrectionDisabled()
                .multilineTextAlignment(.leading)
            Spacer()
        }
    }
    
    var buildingTypeMenu: some View {
        Picker("", selection: $addressFields.buildingType) {
            ForEach(BuildingType.allCases, id: \.self) { type in
                Text(type.rawValue)
                    .tag(type)
            }
        }.labelsHidden().hSpacing(.leading)
    }
    
    var locationFields: some View {
        Group {
            TextField("City", text: $addressFields.city)
            TextField("Country", text: $addressFields.country)
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
            if !addressFields.currentAddress {
                dateField(title: "End Date", date: Binding(get: {
                    addressFields.endDate ?? .now
                }, set: { value in
                    addressFields.endDate = value
                }))
            }
        }
    }
    
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


// MARK: - AddressFields Model
@Observable
class AddressFields {
    // MARK: - Properties
    var apartmentNumber = ""
    var addressLine1 = ""
    var addressLine2 = ""
    var sublocality = ""
    var city = ""
    var postalCode = ""
    var country = ""
    var startDate = Date()
    var endDate: Date? = nil
    var currentAddress = false
    var buildingType: BuildingType = .flat
    
    // MARK: - Validation
    var isValid: Bool {
        !addressLine1.isEmpty &&
        !city.isEmpty &&
        !country.isEmpty &&
        startDate <= endDate ?? Date.now
    }
    
    init() {}
}

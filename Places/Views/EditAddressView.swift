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
    @State private var isCurrent = false
    @State private var buildingType: BuildingType = .flat

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
                   
                    HStack {
                        buildingTypeMenu
                        Spacer()
                        TextField("Apartment/House Number", text: $apartmentNumber)
                            .keyboardType(.decimalPad)
                    }
                    .hSpacing(.leading)
                    
                    TextField("Postal Code", text: $postcode)

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
                    
                    HStack {
                        Text("Is this your current address?")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Toggle("", isOn: $isCurrent)
                            .labelsHidden()
                            .tint(.green)
                    }
                    
                    HStack {
                        Text("Start Date")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        Spacer()
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                    
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
        .presentationDetents([.fraction(0.72), .large])
    }
    
    var buildingTypeMenu: some View {
        Menu {
            ForEach(BuildingType.allCases, id: \.self) { type in
                Button {
                    self.buildingType = type
                } label: {
                    Text(type.rawValue)
                }
                .tag(type)
            }
        } label: {
            HStack {
                Text(buildingType.rawValue)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
            }
        }
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
        
        isCurrent = place.isCurrent
        buildingType = place.buildingType

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
    
    private func saveChanges() {
        place.addressLine1 = addressLine1
        place.addressLine2 = addressLine2
        place.apartmentNumber = apartmentNumber
        place.city = city
        place.country = country
        place.postcode = postcode
        place.startDate = startDate
        place.endDate = endDate
        place.sublocality = sublocality
        place.isCurrent = isCurrent
        place.buildingType = buildingType

        dismiss()
    }
}

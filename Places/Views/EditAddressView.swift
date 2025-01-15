//
//  EditAddressView.swift
//  Places
//
//  Created by alidinc on 11/12/2024.
//

import SwiftUI
import SwiftData

struct EditAddressView: View {

    @AppStorage("tint") private var tint: Tint = .blue
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var place: Address

    // Address fields
    @State private var apartmentNumber = ""
    @State private var addressLine1 = ""
    @State private var addressLine2 = ""
    @State private var city = ""
    @State private var sublocality = ""
    @State private var postcode = ""
    @State private var country: String = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var buildingType: BuildingType = .flat
    @State private var isCurrent = false

    // Country and City Picker
    @Environment(CountryViewModel.self) var viewModel

    var body: some View {
        NavigationStack {
            Form {
                // Address Section
                Section(header: Text("Address Details")) {
                    TextField("Address Line 1", text: $addressLine1)
                    TextField("Address Line 2", text: $addressLine2)
                   
                    HStack {
                        buildingTypeMenu
                        Spacer()
                        TextField("Apartment/House Number", text: $apartmentNumber)
                            .keyboardType(.decimalPad)
                    }
                    .hSpacing(.leading)
                    
                    TextField("Postal Code", text: $postcode)

                    HStack {
                        Text("Country")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        
                        Spacer()
                        TextField("Country", text: $country)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("City")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        Spacer()
                        TextField("City", text: $city)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Sublocality")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        Spacer()
                        TextField("State", text: $sublocality)
                            .multilineTextAlignment(.trailing)
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
                    
                    if !isCurrent {
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
                    
                    HStack {
                        Text("Is this your current address?")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Toggle("", isOn: $isCurrent)
                            .labelsHidden()
                            .tint(.green)
                    }
                }
            }
            .navigationTitle("Edit Address")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                 loadPlaceDetails()
            }
            .onDisappear(perform: {
                updateOtherAddressesCurrentStatus()
            })
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
        .presentationDetents([.fraction(0.75), .large])
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
    
    private func updateOtherAddressesCurrentStatus() {
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
    
    @MainActor
    private func loadPlaceDetails() {
        addressLine1 = place.addressLine1
        addressLine2 = place.addressLine2
        apartmentNumber = place.apartmentNumber
        sublocality = place.sublocality ?? ""
        postcode = place.postcode
        country = place.country
        startDate = place.startDate ?? .now
        endDate = place.endDate ?? .now
        isCurrent = place.isCurrent
        buildingType = place.buildingType
        city = place.city
        country = place.country
    }
    
    private func saveChanges() {
        place.addressLine1 = addressLine1
        place.addressLine2 = addressLine2
        place.sublocality = sublocality
        place.apartmentNumber = apartmentNumber
        place.city = city
        place.country = country
        place.postcode = postcode
        place.startDate = startDate
        place.endDate = endDate
        place.isCurrent = isCurrent
        place.buildingType = buildingType

        dismiss()
    }
}

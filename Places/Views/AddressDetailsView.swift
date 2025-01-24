//
//  AddressDetailsView.swift
//  Places
//

import SwiftUI

struct AddressDetailsView: View {
    
    @AppStorage("tint") private var tint: Tint = .blue
    
    @Binding var addressLine1: String
    @Binding var addressLine2: String
    @Binding var apartmentNumber: String
    @Binding var postalCode: String
    @Binding var city: String
    @Binding var buildingType: BuildingType
    @Binding var country: FlagData?
    @Binding var startDate: Date
    @Binding var endDate: Date?
    @Binding var isCurrent: Bool
    @Binding var addressOwner: ResidentType
    @Binding var showCountries: Bool
    
    var body: some View {
        Section("Address Details") {
            Group {
                TextField("Address Line 1", text: $addressLine1).frame(height: 22)
                TextField("Address Line 2", text: $addressLine2)

                HStack(alignment: .center, spacing: 8) {
                    buildingTypeMenu

                    Divider().frame(width: 1)
                    TextField("Apt/House #", text: $apartmentNumber).frame(maxHeight: .infinity)
                    Divider().frame(width: 1)
                    TextField("Postal Code", text: $postalCode)
                }
                .frame(height: 22)
                
                TextField("City", text: $city)

                countryButton

                if addressOwner == .mine {
                    VStack(spacing: 8) {
                        dateAndCurrentStatusSection
                    }
                }
            }
            .listRowSeparatorTint(StyleManager.shared.listRowSeparator)
            .listRowBackground(StyleManager.shared.listRowBackground)
            .textFieldStyle(.plain)
            .autocorrectionDisabled()
        }
    }
    
    private var countryButton: some View {
        Button {
            showCountries = true
        } label: {
            HStack {
                if let countryData = country, !countryData.name.isEmpty {
                    Text(countryData.unicodeFlag)
                    Text(countryData.name)
                } else {
                    Text("Select Country")
                        .font(.subheadline.weight(.medium))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(tint.color)
        }
    }
    
    private var buildingTypeMenu: some View {
        Menu {
            Picker(selection: $buildingType) {
                ForEach(BuildingType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            } label: {
                Text(buildingType.rawValue)
            }
            .pickerStyle(.inline)
        } label: {
            HStack {
                Text(buildingType.rawValue)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var dateAndCurrentStatusSection: some View {
        VStack(spacing: 8) {
            datePicker("Start Date", selection: $startDate)
            
            if !isCurrent {
                datePicker("End Date", selection: Binding(get: {
                    endDate ?? .now
                }, set: { value in
                    endDate = value
                }))
            }
            
            Divider().background(StyleManager.shared.dividerColor)

            HStack {
                Text("Is this your current address?")
                    .foregroundStyle(.secondary)
                Spacer()
                Toggle("", isOn: $isCurrent)
                    .labelsHidden()
                    .tint(.green)
            }
        }
    }
    
    private func datePicker(_ title: String, selection: Binding<Date>) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            DatePicker("", selection: selection, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
        }
    }
}

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
    @State private var sublocality = ""
    @State private var locality = ""
    @State private var city = ""
    @State private var postalCode = ""
    @State private var country = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var buildingType: BuildingType = .house

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
                // Address Section
                Section(header: Text("Address Details")) {
                    TextField("Address Line 1", text: $addressLine1)
                    TextField("Address Line 2", text: $addressLine2)
                
                    TextField("Apartment/House/Building Number", text: $apartmentNumber)
                        .keyboardType(.decimalPad)

                    Picker("Country", selection: $selectedCountry) {
                        Text("Select a Country").tag("Select")
                        ForEach(viewModel.countries, id: \.hashValue) { country in
                            Text(country.country).tag(country)
                        }
                    }
                    .onChange(of: selectedCountry) { _, newValue in
                        selectedCity = ""
                        country = newValue?.country ?? ""
                    }
                    
                    if let selectedCountry {
                        Picker("City", selection: $selectedCity) {
                            Text("Select a City").tag("Select")
                            ForEach(selectedCountry.cities.sorted(by: { $0 < $1 }), id: \.self) { city in
                                Text(city).tag(city)
                            }
                        }
                        .onChange(of: selectedCity) { _, newValue in
                            city = newValue
                        }
                    }

                    TextField("Postal Code", text: $postalCode)
                }
                
                Section("Building Type") {
                    buildingTypePicker
                        .listRowInsets(.init(top: 12, leading: 12, bottom: 12, trailing: 12))
                }
               
                if buildingType != .place  {
                    Section(header: Text("Dates")) {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Add Address Manually")
            .navigationBarTitleDisplayMode(.inline)
            .animation(.smooth, value: buildingType)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Input"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
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
        }
        .presentationDetents([.fraction(0.72), .large])
    }
    
    private var buildingTypePicker: some View {
        CustomPlaceTypePicker(type: $buildingType)
    }

    private func isFormValid() -> Bool {
        !addressLine1.isEmpty &&
        !city.isEmpty &&
        !country.isEmpty &&
        startDate <= endDate
    }

    private func savePlace() {
        guard isFormValid() else {
            alertMessage = "Please fill in all required fields."
            showAlert = true
            return
        }
        
        let country = viewModel.countries.first(where: { $0.country.lowercased() == self.country })

        let place = Address(
            apartmentNumber: apartmentNumber,
            addressLine1: addressLine1,
            addressLine2: addressLine2,
            city: city,
            postcode: postalCode,
            country: country,
            placeType: .residential,
            buildingType: buildingType,
            startDate: startDate,
            endDate: endDate
        )

        modelContext.insert(place)
        try? modelContext.save()
        dismiss()
    }
}


struct CustomPlaceTypePicker: View {
    
    @Binding var type: BuildingType
    
    var body: some View {
        HStack {
            ForEach(BuildingType.allCases, id: \.self) { placeType in
                Button {
                    withAnimation {
                        type = placeType
                    }
                } label: {
                    CustomPickerItem(type: placeType, isSelected: type == placeType)
                }
                .contentShape(.rect)
                .buttonStyle(.plain)
            }
        }
    }
}

struct CustomPickerItem: View {
    
    @AppStorage("tint") private var tint: Tint = .blue
    let type: BuildingType
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Image(systemName: type.iconName)
            Text(type.rawValue.capitalized)
        }
        .font(.subheadline)
        .foregroundStyle(.white)
        .padding(8)
        .hSpacing(.center)
        .vSpacing(.center)
        .frame(height: 40)
        .background(isSelected ? tint.color.gradient : Color.secondary.gradient,
                    in: .rect(cornerRadius: 10))
    }
}

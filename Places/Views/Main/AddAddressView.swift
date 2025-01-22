//
//  AddAddressView.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import SwiftUI
import SwiftData

struct AddAddressView: View {
    
    @AppStorage("current") private var currentAddressId = ""
    @AppStorage("tint") private var tint: Tint = .blue
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(CountryViewModel.self) var viewModel
    @Environment(ContactsManager.self) private var contactsManager
    
    @State private var addressFields = AddressFields()
    @State private var showContactsList = false
    @State private var showCountries = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var previewURL: URL?
    @Query private var savedAddresses: [Address]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                addressOwnerPicker
                List {
                    addressSection
                    if addressFields.addressOwner == .friend {
                        OwnerDetailsView(
                            ownerName: $addressFields.ownerName,
                            relationship: $addressFields.relationship,
                            showContactsList: $showContactsList,
                            image: $addressFields.image
                        )
                    }
                    DocumentsSectionView(documents: $addressFields.documents, previewURL: $previewURL)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .scrollContentBackground(.hidden)
            .quickLookPreview($previewURL)
            .animation(.easeInOut, value: addressFields.addressOwner)
            .toolbarRole(.editor)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        savePlace()
                    }
                    .disabled(!addressFields.isValid)
                    .foregroundStyle(addressFields.isValid ? tint.color.gradient : Color.secondary.gradient)
                }
                
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .principal) { Text("Add a new address").font(.headline.weight(.semibold)) }
            }
            .sheet(isPresented: $showCountries) {
                CountrySelectionView(countryData: $addressFields.country)
            }
            .sheet(isPresented: $showContactsList) {
                ContactsView {
                    addressFields.ownerName = $0.name
                    addressFields.image = $0.image
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Input"),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
        .interactiveDismissDisabled()
        .presentationDetents([.medium, .fraction(0.95)])
        .presentationBackground(.regularMaterial)
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(20)
    }

    private func savePlace() {
        guard addressFields.isValid else {
            alertMessage = "Please fill in all required fields."
            showAlert = true
            return
        }
        
        if let place = addressFields.create() {
            modelContext.insert(place)
            try? modelContext.save()
            if addressFields.isCurrent {
                currentAddressId = place.id
            }
            NotificationCenter.default.post(Notification(name: Constants.Notifications.addressesChanged, object: place))
            dismiss()
        }
    }
}

extension AddAddressView {
    
    // MARK: - Subviews
    var addressSection: some View {
        AddressDetailsView(
            addressLine1: $addressFields.addressLine1,
            addressLine2: $addressFields.addressLine2,
            apartmentNumber: $addressFields.apartmentNumber,
            postalCode: $addressFields.postalCode,
            city: $addressFields.city,
            buildingType: $addressFields.buildingType,
            country: $addressFields.country,
            startDate: $addressFields.startDate,
            endDate: $addressFields.endDate,
            isCurrent: $addressFields.isCurrent,
            addressOwner: $addressFields.addressOwner,
            showCountries: $showCountries
        )
    }
    
    var addressOwnerPicker: some View {
        CustomPickerView(selection: $addressFields.addressOwner, items: ResidentType.allCases) { $0.rawValue }
            .padding(.top)
            .padding(.horizontal)
    }
}

@Observable
class AddressFields {
    // MARK: - Properties
    var apartmentNumber = ""
    var addressLine1 = ""
    var addressLine2 = ""
    var sublocality = ""
    var city = ""
    var postalCode = ""
    var country: FlagData?
    var startDate = Date()
    var endDate: Date? = nil
    var buildingType: BuildingType = .flat
    var addressOwner: ResidentType = .mine
    var ownerName = ""
    var relationship = ""
    var isCurrent = false
    var image: UIImage?
    var documents: [DocumentItem] = []
    
    // MARK: - Validation
    var isValid: Bool {
        guard let country else {
            return false
        }
        
        return !addressLine1.isEmpty &&
        !city.isEmpty &&
        !country.name.isEmpty &&
        startDate <= endDate ?? Date.now
    }
    
    init() {}
    
    
    func create() -> Address? {
        let place = Address(
            apartmentNumber: apartmentNumber,
            addressLine1: addressLine1,
            addressLine2: addressLine2,
            sublocality: sublocality,
            city: city,
            postcode: postalCode,
            country: country ?? .init(name: "", iso2: "", iso3: "", unicodeFlag: ""),
            buildingType: buildingType,
            startDate: startDate,
            endDate: endDate,
            residentType: addressOwner
        )
        
        // Create ResidentProperty if it's a friend's address
        if addressOwner == .friend {
            if let imageData = image?.jpegData(compressionQuality: 0.8) {
                let residentProperty = ResidentProperty(
                    name: ownerName,
                    relationship: relationship,
                    image: imageData
                )
                place.residentProperty = residentProperty
            }
        }
        
        // Add documents to the place
        place.documents = documents
        
        // Add default checklist items if it's the user's address
        if addressOwner == .mine {
            let checklistItems = DefaultChecklistItems.items.map { itemTitle in
                ChecklistItem(title: itemTitle, isCompleted: false, addressId: place.id)
            }
            place.checklistItems = checklistItems
        }
        
        return place
    }
}

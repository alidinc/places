//
//  AddAddressView.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import PhotosUI
import SwiftUI
import SwiftData

struct AddAddressView: View {
    
    @AppStorage("current") private var currentAddressId = ""
    @AppStorage("tint") private var tint: Tint = .blue
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(CountryViewModel.self) var viewModel
    @Environment(ContactsManager.self) private var contactsManager
    @Environment(LocationsManager.self) private var locationsManager
    
    @State private var addressFields = AddAddressViewModel()
    @State private var showContactsList = false
    @State private var showImagePicker = false
    @State private var showCountries = false
    @State private var showLocationSearch = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var previewURL: URL?
    @Query private var savedAddresses: [Address]
    
    var body: some View {
        NavigationStack {
            VStack {
                addressOwnerPicker

                List {
                    if addressFields.addressLine1.isEmpty {
                        LocationRecommendationView(onAddressSelected: {
                            useRecommendedAddress($0)
                        }, showLocationSearch: $showLocationSearch)
                    }

                    addressSection
                    
                    if addressFields.addressOwner == .friend {
                        OwnerDetailsView(
                            ownerName: $addressFields.ownerName,
                            relationship: $addressFields.relationship,
                            showContactsList: $showContactsList,
                            showImagePicker: $showImagePicker,
                            image: $addressFields.image
                        )
                    }

                    Spacer(minLength: 50).listRowBackground(Color.clear)
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

                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        addressFields.confirmDiscard {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .principal) { Text("Add a new address").font(.headline.weight(.semibold)) }
            }
            .sheet(isPresented: $showImagePicker) { ImagePicker(image: $addressFields.image) }
            .sheet(isPresented: $showCountries) { CountrySelectionView(countryData: $addressFields.country) }
            .sheet(isPresented: $showContactsList) {
                ContactsView {
                    addressFields.ownerName = $0.name
                    if addressFields.image == nil {
                        addressFields.image = $0.image
                    }
                }
            }
            .sheet(isPresented: $showLocationSearch) {
                LocationSearchView { place in
                    useSearchResult(place)
                    showLocationSearch = false
                }
            }
            .onAppear { HapticsManager.shared.vibrateForSelection() }
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
        .confirmationDialog(
            "Are you sure you want to discard your changes?",
            isPresented: $addressFields.showingDiscardConfirmation,
            titleVisibility: .visible
        ) {
            Button("Discard Changes", role: .destructive) {
                addressFields.onConfirmDiscard()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
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
            .padding(.horizontal, 22)
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
    
    private func handleImageSelection(_ selection: PhotosPickerItem?) {
        guard let selection = selection else { return }
        
        Task {
            do {
                guard let data = try await selection.loadTransferable(type: Data.self) else { return }
                if let newImage = UIImage(data: data) {
                    await MainActor.run {
                        addressFields.image = newImage
                    }
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }
    
    private func useRecommendedAddress(_ place: CLPlacemark) {
        addressFields.addressLine1 = place.thoroughfare ?? place.subThoroughfare ?? place.subLocality ?? ""
        addressFields.addressLine2 = place.subThoroughfare ?? ""
        addressFields.city = place.locality ?? ""
        addressFields.postalCode = place.postalCode ?? ""

        // Find matching country in viewModel.countryFlags
        if let countryCode = place.isoCountryCode,
           let country = viewModel.countryFlags.first(where: { $0.iso2.lowercased() == countryCode.lowercased() }) {
            addressFields.country = country
        }
    }

    private func useSearchResult(_ place: CLPlacemark) {
        addressFields.addressLine1 = place.thoroughfare ?? place.subThoroughfare ?? place.subLocality ?? ""
        addressFields.addressLine2 = place.subThoroughfare ?? place.subAdministrativeArea ?? ""
        addressFields.city = place.locality ?? ""
        addressFields.postalCode = place.postalCode ?? ""

        if let countryCode = place.isoCountryCode,
           let foundCountry = viewModel.countryFlags.first(where: { $0.iso2.lowercased() == countryCode.lowercased() }) {
            addressFields.country = foundCountry
        }
    }
}

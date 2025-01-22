//
//  EditAddressView.swift
//  Places
//
//  Created by alidinc on 11/12/2024.
//

import PhotosUI
import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import QuickLook

struct EditAddressView: View {
    
    @AppStorage("current") private var currentAddressId = ""
    @AppStorage("tint") private var tint: Tint = .blue
    @Bindable var place: Address
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(CountryViewModel.self) var viewModel
    
    @State private var editVM: EditAddressViewModel
    @State private var showImagePicker = false
    
    init(place: Address) {
        self.place = place
        self.editVM = EditAddressViewModel(place: place)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                addressTypePicker
                List {
                    addressDetails
                    ownerTypeView
                    documentsSection
                    checklistSection
                    postcodeDetails
                    Spacer(minLength: 50).listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
            }
            .toolbarRole(.editor)
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear { NotificationCenter.default.post(name: Constants.Notifications.editingAddress, object: nil) }
            .onAppear { NotificationCenter.default.post(name: Constants.Notifications.editingAddress, object: place) }
            .onAppear { HapticsManager.shared.vibrateForSelection() }
            .onAppear { editVM.loadPlaceDetails(from: place) }
            .quickLookPreview($editVM.previewURL)
            .sheet(isPresented: $editVM.showCountries) { CountrySelectionView(countryData: $editVM.countryData) }
            .sheet(isPresented: $editVM.showChecklist) { ChecklistView(place: place) }
            .sheet(isPresented: $editVM.showContactsList) {
                ContactsView {
                    editVM.ownerName = $0.name
                    if editVM.image == nil {
                        editVM.image = $0.image
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { doneButton }
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .principal) { Text("Edit address").font(.headline.weight(.semibold)) }
            }
            .photosPicker(
                isPresented: $showImagePicker,
                selection: .init(
                    get: { nil },
                    set: { newValue in
                        handleImageSelection(newValue)
                    }
                )
            )
        }
        .interactiveDismissDisabled()
        .presentationDetents([.medium, .fraction(0.99)])
        .presentationCornerRadius(20)
        .presentationDragIndicator(.hidden)
        .presentationBackground(.regularMaterial)
    }
    
    private var doneButton: some View {
        Button("Done") {
            editVM.saveChanges(place: place, modelContext: modelContext)
            if editVM.isCurrent {
                currentAddressId = place.id
            } else {
                currentAddressId = ""
            }
            dismiss()
        }
        .disabled(editVM.isInvalidDate)
        .foregroundStyle(tint.color.gradient)
    }
    
    private var documentsSection: some View {
        DocumentsSectionView(
            documents: .init(
                get: { place.documents },
                set: { place.documents = $0 }
            ),
            previewURL: $editVM.previewURL
        )
    }
    
    @ViewBuilder
    private var ownerTypeView: some View {
        if editVM.addressOwner == .friend {
            OwnerDetailsView(
                ownerName: $editVM.ownerName,
                relationship: $editVM.relationship,
                showContactsList: $editVM.showContactsList,
                showImagePicker: $showImagePicker,
                image: $editVM.image
            )
        }
    }
    
    @ViewBuilder
    private var addressTypePicker: some View {
        CustomPickerView(selection: $editVM.addressOwner, items: ResidentType.allCases) { $0.rawValue }
            .padding(.top)
            .padding(.horizontal)
    }
    
    private var addressDetails: some View {
        AddressDetailsView(
            addressLine1: $editVM.addressLine1,
            addressLine2: $editVM.addressLine2,
            apartmentNumber: $editVM.apartmentNumber,
            postalCode: $editVM.postcode,
            city: $editVM.city,
            buildingType: $editVM.buildingType,
            country: $editVM.countryData,
            startDate: $editVM.startDate,
            endDate: $editVM.endDate,
            isCurrent: $editVM.isCurrent,
            addressOwner: $editVM.addressOwner,
            showCountries: $editVM.showCountries
        )
    }
    
    private var postcodeDetails: some View {
        PostcodeDetailsView(
            country: place.country.name,
            isLoading: $editVM.isLoading,
            postcodeResult: $editVM.postcodeResult,
            errorMessage: $editVM.errorMessage
        )
    }

    private var checklistSection: some View {
        ChecklistSectionView(place: place, showChecklist: $editVM.showChecklist)
    }

    @ViewBuilder
    private func InfoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .multilineTextAlignment(.trailing)
        }
        .hSpacing(.leading)
        .padding(.vertical, 4)
    }
    
    private func handleImageSelection(_ selection: PhotosPickerItem?) {
        guard let selection = selection else { return }
        
        Task {
            do {
                guard let data = try await selection.loadTransferable(type: Data.self) else { return }
                if let newImage = UIImage(data: data) {
                    await MainActor.run {
                        editVM.image = newImage
                    }
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }
}

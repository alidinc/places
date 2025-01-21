//
//  EditAddressView.swift
//  Places
//
//  Created by alidinc on 11/12/2024.
//

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
    
    init(place: Address) {
        self.place = place
        self.editVM = EditAddressViewModel(place: place)
    }
    
    var body: some View {
        NavigationStack {
            List {
                if place.addressOwner == .friend {
                    
                }
                addressDetails
                documentsSection
                checklistSection
                postcodeDetails
                Spacer(minLength: 50).listRowBackground(Color.clear)
            }
            .toolbarRole(.editor)
            .scrollContentBackground(.hidden)
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .onDisappear { NotificationCenter.default.post(name: Constants.Notifications.editingAddress, object: nil) }
            .onAppear { NotificationCenter.default.post(name: Constants.Notifications.editingAddress, object: place) }
            .onAppear { editVM.loadPlaceDetails(from: place) }
            .quickLookPreview($editVM.previewURL)
            .sheet(isPresented: $editVM.showCountries) { CountrySelectionView(countryData: $editVM.countryData) }
            .sheet(isPresented: $editVM.showChecklist) { ChecklistView(place: place) }
            .sheet(isPresented: $editVM.showContactsList) { ContactsView { editVM.ownerName = $0.name } }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { saveButton }
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .principal) { Text("Edit address").font(.headline.weight(.semibold)) }
            }
        }
        .presentationDetents([.medium, .fraction(0.95)])
        .presentationCornerRadius(20)
        .presentationBackground(.ultraThinMaterial)
    }
    
    private var saveButton: some View {
        Button("Save") {
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
            addressOwner: $place.addressOwner,
            showCountries: $editVM.showCountries
        )
        .listRowBackground(Color.gray.opacity(0.25))
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
}

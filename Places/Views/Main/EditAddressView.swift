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
    
    @State private var editVM = EditAddressViewModel()
    @State private var showCancelDialog = false
    @State private var showDeleteConfirmation = false
    
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
                    deleteButton
                    
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
            .sheet(isPresented: $editVM.showImagePicker) { ImagePicker(image: $editVM.image) }
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
            .confirmationDialog(
                "Discard Changes?",
                isPresented: $showCancelDialog,
                titleVisibility: .visible
            ) {
                Button("Discard Changes", role: .destructive) {
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) {}
            } message: {
                Text("Are you sure you want to discard your changes?")
            }
            .confirmationDialog(
                "Delete Address",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    deleteAddress()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this address? This action cannot be undone.")
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { doneButton }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        if editVM.hasUnsavedChanges(place: place) {
                            showCancelDialog = true
                        } else {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .principal) { Text(place.mainAddressDetails).font(.headline.weight(.semibold)) }
            }
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
        if editVM.residentType == .friend {
            OwnerDetailsView(
                ownerName: $editVM.ownerName,
                relationship: $editVM.relationship,
                showContactsList: $editVM.showContactsList,
                showImagePicker: $editVM.showImagePicker,
                image: $editVM.image
            )
        }
    }
    
    @ViewBuilder
    private var addressTypePicker: some View {
        CustomPickerView(selection: $editVM.residentType, items: ResidentType.allCases) { $0.rawValue }
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
            addressOwner: $editVM.residentType,
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
    
    private var deleteButton: some View {
        Section {
            Button {
                showDeleteConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Address")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
            }
        }
        .listRowInsets(.init())
        .listRowBackground(Color.clear)
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
    
    private func deleteAddress() {
        modelContext.delete(place)
        NotificationCenter.default.post(name: Constants.Notifications.deletedAddress, object: place)
        dismiss()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

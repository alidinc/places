//
//  AddAddressViewModel.swift
//  Places
//
//  Created by alidinc on 22/01/2025.
//

import CoreLocation
import SwiftUI

@Observable
class AddAddressViewModel {
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

    var showingDiscardConfirmation = false
    var onConfirmDiscard: () -> Void = {}

    init() {}

    var hasUnsavedChanges: Bool {
        return !addressLine1.isEmpty ||
        !addressLine2.isEmpty ||
        !apartmentNumber.isEmpty ||
        !city.isEmpty ||
        !postalCode.isEmpty ||
        country != nil ||
        addressOwner != .mine ||
        !ownerName.isEmpty ||
        !relationship.isEmpty ||
        image != nil ||
        !documents.isEmpty
    }

    func confirmDiscard(action: @escaping () -> Void) {
        if hasUnsavedChanges {
            onConfirmDiscard = action
            showingDiscardConfirmation = true
        } else {
            action()
        }
    }

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
            place.residentProperty = ResidentProperty(
                name: ownerName,
                relationship: relationship,
                image: image?.jpegData(compressionQuality: 0.8)
            )
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

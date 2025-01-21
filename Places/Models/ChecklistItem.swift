//
//  ChecklistItem.swift
//  Places
//
//  Created by alidinc on 16/01/2025.
//

import Foundation
import SwiftData

@Model
class ChecklistItem: Identifiable {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var addressId: String
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, addressId: String) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.addressId = addressId
    }
}

// Default checklist items
struct DefaultChecklistItems {
    static let items = [
        "Update bank address",
        "Transfer utilities (water, electricity, gas)",
        "Register with local authorities",
        "Update home insurance",
        "Update car insurance",
        "Change address with employer",
        "Register with local healthcare",
        "Set up internet/phone service",
        "Update streaming services",
        "Update online shopping accounts",
        "Forward mail from old address"
    ]
}

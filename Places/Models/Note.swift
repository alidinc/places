//
//  Note.swift
//  Places
//
//  Created by alidinc on 22/01/2024.
//

import Foundation
import SwiftData

@Model
class Note: Identifiable {
    var id: UUID
    var text: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), text: String, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}


//
//  Address.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import Foundation
import SwiftData

@Model
class Place: Identifiable {
    var id = UUID()
    var addressLine: String
    var startDate: Date
    var endDate: Date

    init(addressLine: String, startDate: Date, endDate: Date) {
        self.addressLine = addressLine
        self.startDate = startDate
        self.endDate = endDate
    }
}

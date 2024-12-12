//
//  Address.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import Foundation
import SwiftData

enum PlaceType: String, Codable, CaseIterable {

    case residential = "Residential"
    case place = "Place"

    var icon: String {
        switch self {
        case .residential:
            return "house.fill"
        case .place:
            return "mappin.and.ellipse"
        }
    }
}

@Model
class Place: Identifiable {
    var id = UUID()
    var name: String?
    var apartmentNumber: String
    var addressLine1: String
    var addressLine2: String
    var city: String
    var postcode: String
    var country: String
    var placeType: PlaceType
    var startDate: Date?
    var endDate: Date?

    init(
        id: UUID = UUID(),
        name: String? = nil,
        apartmentNumber: String,
        addressLine1: String,
        addressLine2: String,
        city: String,
        postcode: String,
        country: String,
        placeType: PlaceType,
        startDate: Date? = nil,
        endDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.apartmentNumber = apartmentNumber
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.city = city
        self.postcode = postcode
        self.country = country
        self.placeType = placeType
        self.startDate = startDate
        self.endDate = endDate
    }

    var fullAddress: String {
        var addressLines = [String]()

        if !apartmentNumber.isEmpty {
            addressLines.append(apartmentNumber)
        }

        if let name, !name.isEmpty {
            addressLines.append(name)
        }

        if !city.isEmpty {
            addressLines.append(city)
        }

        if !postcode.isEmpty {
            addressLines.append(postcode)
        }

        if !country.isEmpty {
            addressLines.append(country)
        }

        return addressLines.joined(separator: ", ")
    }
}

extension Place {
    var durationString: String {
        guard let start = startDate else {
            return ""
        }

        // If endDate is nil, use the current date for calculation
        let end = endDate ?? Date()

        let components = Calendar.current.dateComponents([.year, .month, .day], from: start, to: end)

        // Format the duration string (this is just an example)
        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0

        var parts: [String] = []

        if years > 0 {
            parts.append("\(years) year\(years > 1 ? "s" : "")")
        }
        if months > 0 {
            parts.append("\(months) month\(months > 1 ? "s" : "")")
        }
        if days > 0 && years == 0 { // Only show days if less than a month/year
            parts.append("\(days) day\(days > 1 ? "s" : "")")
        }

        if parts.isEmpty {
            return "Less than a day"
        } else {
            return parts.joined(separator: ", ")
        }
    }
}

//
//  Address.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import Foundation
import SwiftData

@Model
class Address: Identifiable {

    var id = UUID()
    var title: String?
    var name: String?
    var apartmentNumber: String
    var addressLine1: String
    var addressLine2: String
    var city: String
    var postcode: String
    var country: Country?
    var sublocality: String?
    var locality: String?
    var placeType: AddressType
    var buildingType: BuildingType
    var startDate: Date?
    var endDate: Date?

    init(
        id: UUID = UUID(),
        title: String? = nil,
        name: String? = nil,
        apartmentNumber: String,
        addressLine1: String,
        addressLine2: String,
        sublocality: String? = nil,
        locality: String? = nil,
        city: String,
        postcode: String,
        country: Country?,
        placeType: AddressType,
        buildingType: BuildingType,
        startDate: Date? = nil,
        endDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.name = name
        self.apartmentNumber = apartmentNumber
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.sublocality = sublocality
        self.locality = locality
        self.city = city
        self.postcode = postcode
        self.country = country
        self.placeType = placeType
        self.buildingType = buildingType
        self.startDate = startDate
        self.endDate = endDate
    }
}

extension Address {

    var fullAddress: String {
        var addressLines = [String]()
        
        if let title, !title.isEmpty, let name, title != name {
            addressLines.append(title)
        }

        if !apartmentNumber.isEmpty {
            if buildingType == .flat {
                addressLines.append("\(buildingType.rawValue) \(apartmentNumber)")
            } else {
                addressLines.append(apartmentNumber)
            }
        }
        
        if let name, !name.isEmpty {
            addressLines.append(name)
        } else {
            if !addressLine1.isEmpty {
                if !addressLine2.isEmpty {
                    addressLines.append("\(addressLine2) \(addressLine1)")
                } else {
                    addressLines.append(addressLine1)
                }
            }
        }

        if let sublocality, !sublocality.isEmpty {
            addressLines.append(sublocality)
        }
        
        if let locality, !locality.isEmpty {
            addressLines.append(locality)
        }

        if !city.isEmpty {
            addressLines.append(city)
        }

        if !postcode.isEmpty {
            addressLines.append(postcode)
        }

        if let country {
            addressLines.append(country.country)
        }

        return addressLines.joined(separator: ", ")
    }

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
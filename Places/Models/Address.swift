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
    var apartmentNumber: String
    var addressLine1: String
    var addressLine2: String
    var sublocality: String?
    var city: String
    var postcode: String
    var country: String
    var buildingType: BuildingType
    var startDate: Date?
    var endDate: Date?
    var isCurrent: Bool

    init(
        id: UUID = UUID(),
        apartmentNumber: String,
        addressLine1: String,
        addressLine2: String,
        sublocality: String? = nil,
        city: String,
        postcode: String,
        country: String,
        buildingType: BuildingType,
        startDate: Date? = nil,
        endDate: Date? = nil,
        isCurrent: Bool
    ) {
        self.id = id
        self.apartmentNumber = apartmentNumber
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.sublocality = sublocality
        self.city = city
        self.postcode = postcode
        self.country = country
        self.buildingType = buildingType
        self.startDate = startDate
        self.endDate = endDate
        self.isCurrent = isCurrent
    }
}

extension Address {

    var fullAddress: String {
        var addressLines = [String]()
        
        if !apartmentNumber.isEmpty {
            if buildingType == .flat {
                addressLines.append("\(buildingType.rawValue) \(apartmentNumber)")
            } else {
                addressLines.append(apartmentNumber)
            }
        }
        
        if !addressLine1.isEmpty {
            if !addressLine2.isEmpty {
                addressLines.append("\(addressLine2) \(addressLine1)")
            } else {
                addressLines.append(addressLine1)
            }
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
    
    var mainAddressDetails: String {
        var mainAddressDetails = [String]()
        
        if !apartmentNumber.isEmpty {
            mainAddressDetails.append("\(buildingType == .flat ? "Flat " : "")\(apartmentNumber)")
        }
        
        if !addressLine1.isEmpty {
            mainAddressDetails.append(addressLine1)
        }
        
        if !addressLine2.isEmpty {
            mainAddressDetails.append(addressLine2)
        }
        
        return mainAddressDetails.joined(separator: ", ")
    }
    
    var localityDetails: String {
        var localityDetails = [String]()
        
        if !city.isEmpty {
            localityDetails.append(city)
        }
        if let sublocality, !sublocality.isEmpty {
            localityDetails.append(sublocality)
        }
        if !postcode.isEmpty {
            localityDetails.append(postcode)
        }
        
        if !country.isEmpty {
            localityDetails.append(country)
        }
        
        return localityDetails.joined(separator: ", ")
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

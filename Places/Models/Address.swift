//
//  Address.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import Foundation
import CoreLocation
import MapKit
import SwiftData
import SwiftUI

@Model
class Address: Identifiable {
    
    var id: String
    var apartmentNumber: String
    var addressLine1: String
    var addressLine2: String
    var sublocality: String?
    var city: String
    var postcode: String
    var country: FlagData
    var buildingType: BuildingType
    var startDate: Date?
    var endDate: Date?
    var hasSeenChecklist: Bool = false
    var residentType: ResidentType
    var residentProperty: ResidentProperty?
    var latitude: Double?
    var longitude: Double?
    
    @Relationship(deleteRule: .cascade) var notes: [Note] = []
    @Relationship(deleteRule: .cascade) var checklistItems: [ChecklistItem] = []
    @Relationship(deleteRule: .cascade) var documents: [DocumentItem] = []
    
    init(
        id: String = UUID().uuidString,
        apartmentNumber: String,
        addressLine1: String,
        addressLine2: String,
        sublocality: String? = nil,
        city: String,
        postcode: String,
        country: FlagData,
        buildingType: BuildingType,
        startDate: Date? = nil,
        endDate: Date? = nil,
        residentType: ResidentType = .mine,
        residentProperty: ResidentProperty? = nil
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
        self.residentType = residentType
        self.residentProperty = residentProperty
    }
}

@Model
class ResidentProperty: Identifiable {
    var id = UUID()
    var name: String
    var relationship: String?
    var image: Data?
    
    init(id: UUID = UUID(), name: String, relationship: String? = nil, image: Data? = nil) {
        self.id = id
        self.name = name
        self.relationship = relationship
        self.image = image
    }
}

@Model
class DocumentItem: Identifiable {
    var id = UUID()
    var name: String
    var data: Data
    var type: DocumentType
    var uploadDate: Date
    
    init(id: UUID = UUID(), name: String, data: Data, type: DocumentType, uploadDate: Date = Date()) {
        self.id = id
        self.name = name
        self.data = data
        self.type = type
        self.uploadDate = uploadDate
    }
}

enum DocumentType: String, Codable, CaseIterable {
    case rentalAgreement = "Rental Agreement"
    case utilityBill = "Utility Bill"
    case other = "Other"
}

enum ResidentType: String, Codable, CaseIterable {
    
    case mine = "Personal"
    case friend = "Others"
    
    var icon: String {
        switch self {
        case .mine:
            return "house.fill"
        case .friend:
            return "person.2.fill"
        }
    }
}


extension Address {
    
    func updateCoordinates() async {
        do {
            if let location = try await CLGeocoder().geocodeAddressString(fullAddress).first?.location {
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
            }
        } catch {
            print("Failed to geocode address: \(error)")
        }
    }
    
    var durationInDays: Int {
        guard let start = startDate else { return 0 }
        let end = endDate ?? Date()
        return Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
    }
    
    var formattedDuration: String {
        let years = durationInDays / 365
        let months = (durationInDays % 365) / 30
        
        if years > 0 {
            return "\(years) year\(years > 1 ? "s" : "")\(months > 0 ? " \(months) month\(months > 1 ? "s" : "")" : "")"
        } else if months > 0 {
            return "\(months) month\(months > 1 ? "s" : "")"
        } else {
            return "\(durationInDays) day\(durationInDays != 1 ? "s" : "")"
        }
    }
    
    var encodedAddress: String {
        let address = [addressLine1, addressLine2, city, postcode, country.name]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
        
        return address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
    
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
        
        if  !country.name.isEmpty {
            addressLines.append(country.name)
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
        
        if !country.name.isEmpty {
            localityDetails.append(country.name)
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

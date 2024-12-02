//
//  Address.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import Foundation
import SwiftData

enum PlaceType: String, Codable, CaseIterable {
    case residentialTenancy = "Residential Tenancy"
    case placeToVisit = "Place to Visit"

    var sfSymbolName: String {
        switch self {
        case .residentialTenancy:
            return "house.fill"
        case .placeToVisit:
            return "mappin.and.ellipse"
        }
    }
}

@Model
class Place: Identifiable {
    var id = UUID()
    var addressLine: String
    var placeType: PlaceType
    var startDate: Date?
    var endDate: Date?

    init(addressLine: String, placeType: PlaceType, startDate: Date? = nil, endDate: Date? = nil) {
        self.addressLine = addressLine
        self.placeType = placeType
        self.startDate = startDate
        self.endDate = endDate
    }
}

extension Place {
    var durationString: String {
        guard placeType == .residentialTenancy, let startDate = startDate, let endDate = endDate else {
            return ""
        }

        let calendar = Calendar.current

        guard startDate <= endDate else {
            return "Invalid date range"
        }

        let components = calendar.dateComponents([.year, .month, .day], from: startDate, to: endDate)
        guard let years = components.year, let months = components.month else {
            return ""
        }

        if years == 0 && months == 0 {
            return "Within a month"
        } else if years == 0 {
            return "\(months) month\(months > 1 ? "s" : "") ago"
        } else {
            let monthsPart = months > 0 ? ", \(months) month\(months > 1 ? "s" : "")" : ""
            return "\(years) year\(years > 1 ? "s" : "")\(monthsPart) ago"
        }
    }
}

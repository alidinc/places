//
//  SearchResult.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import Foundation
import MapKit

class SearchResult: Identifiable, Hashable {
    
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    var title: String
    let placemark: CLPlacemark

    init(coordinate: CLLocationCoordinate2D, title: String, placemark: CLPlacemark) {
        self.coordinate = coordinate
        self.title = title
        self.placemark = placemark
    }

    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var searchAddress: String {
        var addressLines: [String] = []
        var firstLineComponents: [String] = []

        if let name = placemark.name, !name.isEmpty {
            firstLineComponents.append(name)
        }

        if !firstLineComponents.isEmpty {
            addressLines.append(firstLineComponents.joined(separator: ", "))
        }
        
        if let sublocality = placemark.subLocality, !sublocality.isEmpty {
            addressLines.append(sublocality)
        }

        // Add other address components
        if let locality = placemark.locality, !locality.isEmpty {
            addressLines.append(locality)
        }

        if let administrativeArea = placemark.administrativeArea, !administrativeArea.isEmpty {
            addressLines.append(administrativeArea)
        }

        if let postalCode = placemark.postalCode {
            addressLines.append(postalCode)
        }

        if let country = placemark.country {
            addressLines.append(country)
        }

        return addressLines.joined(separator: ", ")
    }
}

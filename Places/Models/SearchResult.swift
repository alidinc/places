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
    var detailedAddress: String
    let placemark: CLPlacemark

    init(coordinate: CLLocationCoordinate2D, title: String, detailedAddress: String, placemark: CLPlacemark) {
        self.coordinate = coordinate
        self.title = title
        self.detailedAddress = detailedAddress
        self.placemark = placemark
    }

    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

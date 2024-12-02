//
//  SearchResultsView.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import SwiftUI
import MapKit

struct SearchResultView: View {
    let mapItem: MKMapItem

    var body: some View {
        VStack(alignment: .leading) {
            Text(firstLine)
                .font(.headline)

            Text(remainingAddress)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var firstLine: String {
        let placemark = mapItem.placemark
        var components: [String] = []

        if let subThoroughfare = placemark.subThoroughfare {
            components.append(subThoroughfare)
        }

        if let thoroughfare = placemark.thoroughfare {
            components.append(thoroughfare)
        }

        return components.joined(separator: " ")
    }

    private var remainingAddress: String {
        let placemark = mapItem.placemark
        var components: [String] = []

        if let locality = placemark.locality {
            components.append(locality)
        }

        if let administrativeArea = placemark.administrativeArea {
            components.append(administrativeArea)
        }

        if let postalCode = placemark.postalCode {
            components.append(postalCode)
        }

        if let country = placemark.country {
            components.append(country)
        }

        return components.joined(separator: ", ")
    }
}

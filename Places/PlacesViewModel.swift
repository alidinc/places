//
//  AddressViewModel.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import SwiftUI
import MapKit

@Observable
class PlacesViewModel {

    var searchResults: [MKMapItem] = []
    var searchQuery: String = ""

    func searchAddress(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)

        search.start { [weak self] response, error in
            if let response = response {
                DispatchQueue.main.async {
                    self?.searchResults = response.mapItems
                }
            }
        }
    }
}

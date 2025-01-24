//
//  LocationLookupService.swift
//  Places
//

import SwiftUI
import MapKit

@Observable
class LocationLookupService: NSObject, MKLocalSearchCompleterDelegate {
    // MARK: - Properties
    var searchResults: [MKLocalSearchCompletion] = []
    
    private var searchCompleter: MKLocalSearchCompleter!
    private var debounceTimer: Timer?
    
    // MARK: - Initialization
    override init() {
        super.init()
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter.delegate = self
       
    }
    
    // MARK: - MKLocalSearchCompleterDelegate
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search failed with error: \(error.localizedDescription)")
    }
    
    // MARK: - Search Methods
    func performSearch(query: String, completion: @escaping () -> Void) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.searchCompleter.queryFragment = query
            completion()
        }
    }
    
    func getPlacemark(from completion: MKLocalSearchCompletion) async -> CLPlacemark? {
        return await withCheckedContinuation { continuation in
            let searchRequest = MKLocalSearch.Request(completion: completion)
            let search = MKLocalSearch(request: searchRequest)
            
            search.start { response, error in
                if let placemark = response?.mapItems.first?.placemark {
                    continuation.resume(returning: placemark)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}

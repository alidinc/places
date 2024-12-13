//
//  CountryViewModel.swift
//  Places
//
//  Created by alidinc on 12/12/2024.
//

import Combine
import SwiftUI

@Observable
class CountryViewModel {

    var countries: [Country] = []
    var countryFlags: [FlagData] = []

    var isLoading = false
    var errorMessage: String?

    init() {
        Task {
            await loadData(resource: "Countries", decodingType: CountryResponse.self) { [weak self] response in
                self?.countries = response.data
            }
            await loadData(resource: "CountryFlags", decodingType: CountryFlag.self) { [weak self] response in
                self?.countryFlags = response.data ?? []
            }
        }
    }

    @MainActor
    private func loadData<T: Decodable>(
        resource: String,
        decodingType: T.Type,
        completion: @escaping (T) -> Void
    ) async {
        isLoading = true
        defer { isLoading = false }

        do {
            guard let fileURL = Bundle.main.url(forResource: resource, withExtension: "json") else {
                throw NSError(domain: "File not found", code: 404, userInfo: nil)
            }
            let data = try Data(contentsOf: fileURL)
            let decodedResponse = try JSONDecoder().decode(decodingType, from: data)
            completion(decodedResponse)
        } catch {
            errorMessage = "Failed to load \(resource) data: \(error.localizedDescription)"
        }
    }
}

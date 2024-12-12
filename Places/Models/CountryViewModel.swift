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
            await fetchCountries()
            await fetchCountryFlags()
        }
    }

    @MainActor
    func fetchCountries() {
        isLoading = true
        errorMessage = nil

        DispatchQueue.global(qos: .background).async {
            do {
                // Locate the file in the app bundle
                guard let fileURL = Bundle.main.url(forResource: "Countries", withExtension: "json") else {
                    throw NSError(domain: "File not found", code: 404, userInfo: nil)
                }

                // Read the file contents
                let data = try Data(contentsOf: fileURL)

                // Decode the JSON
                let decodedResponse = try JSONDecoder().decode(CountryResponse.self, from: data)

                // Update the state on the main thread
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.countries = decodedResponse.data
                }
            } catch {
                // Handle errors
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Failed to load data: \(error.localizedDescription)"
                }
            }
        }
    }

    @MainActor
    func fetchCountryFlags() {
        isLoading = true
        errorMessage = nil

        DispatchQueue.global(qos: .background).async {
            do {
                // Locate the file in the app bundle
                guard let fileURL = Bundle.main.url(forResource: "CountryFlags", withExtension: "json") else {
                    throw NSError(domain: "File not found", code: 404, userInfo: nil)
                }

                // Read the file contents
                let data = try Data(contentsOf: fileURL)

                // Decode the JSON
                let decodedResponse = try JSONDecoder().decode(CountryFlag.self, from: data)

                // Update the state on the main thread
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.countryFlags = decodedResponse.data ?? []
                }
            } catch {
                // Handle errors
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Failed to load data: \(error.localizedDescription)"
                }
            }
        }
    }
}

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
    func fetchCountries() async {
        isLoading = true
        do {
            guard let fileURL = Bundle.main.url(forResource: "Countries", withExtension: "json") else {
                throw NSError(domain: "File not found", code: 404, userInfo: nil)
            }
            let data = try Data(contentsOf: fileURL)
            let decodedResponse = try JSONDecoder().decode(CountryResponse.self, from: data)
            countries = decodedResponse.data
        } catch {
            errorMessage = "Failed to load data: \(error.localizedDescription)"
        }
        isLoading = false
    }

    @MainActor
    func fetchCountryFlags() async {
        isLoading = true
        do {
            guard let fileURL = Bundle.main.url(forResource: "CountryFlags", withExtension: "json") else {
                throw NSError(domain: "File not found", code: 404, userInfo: nil)
            }
            let data = try Data(contentsOf: fileURL)
            let decodedResponse = try JSONDecoder().decode(CountryFlag.self, from: data)
            countryFlags = decodedResponse.data ?? []
        } catch {
            errorMessage = "Failed to load data: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

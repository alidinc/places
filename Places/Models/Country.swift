//
//  Country.swift
//  Places
//
//  Created by alidinc on 12/12/2024.
//

import Foundation

struct CountryResponse: Codable {
    let error: Bool
    let msg: String
    let data: [Country]
}

struct Country: Codable, Hashable {
    let country: String
    let cities: [String]
    
    var lowercasedCountry: String {
        country.lowercased()
    }
    
    var lowercasedCities: [String] {
        cities.map { $0.lowercased() }
    }
}

// MARK: - CountryFlag
struct CountryFlag: Codable {
    let error: Bool?
    let msg: String?
    let data: [FlagData]?
}

// MARK: - Datum
struct FlagData: Codable, Hashable {
    let name, iso2, iso3, unicodeFlag: String
}

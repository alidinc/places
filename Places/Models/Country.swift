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
}

// MARK: - CountryFlag
struct CountryFlag: Codable {
    let error: Bool?
    let msg: String?
    let data: [FlagData]?
}

// MARK: - Datum
struct FlagData: Codable {
    let name, iso2, iso3, unicodeFlag: String?
}

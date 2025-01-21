//
//  LocalCouncil.swift
//  Places
//
//  Created by alidinc on 20/01/2025.
//


import Foundation

// Define the structure of the response
struct PostcodeResponse: Codable {
    let status: Int
    let result: PostcodeResult
}

// Define the structure of the result object
struct PostcodeResult: Codable {
    let postcode: String
    let quality: Int
    let eastings: Int
    let northings: Int
    let country: String
    let nhsHa: String
    let longitude: Double
    let latitude: Double
    let europeanElectoralRegion: String
    let primaryCareTrust: String
    let region: String?
    let lsoa: String
    let msoa: String
    let incode: String
    let outcode: String
    let parliamentaryConstituency: String
    let parliamentaryConstituency2024: String
    let adminDistrict: String
    let parish: String?
    let adminCounty: String?
    let dateOfIntroduction: String
    let adminWard: String
    let ced: String?
    let ccg: String
    let nuts: String
    let pfa: String
    let codes: PostcodeCodes

    enum CodingKeys: String, CodingKey {
        case postcode, quality, eastings, northings, country, nhsHa = "nhs_ha", longitude, latitude
        case europeanElectoralRegion = "european_electoral_region"
        case primaryCareTrust = "primary_care_trust", region, lsoa, msoa, incode, outcode
        case parliamentaryConstituency = "parliamentary_constituency"
        case parliamentaryConstituency2024 = "parliamentary_constituency_2024"
        case adminDistrict = "admin_district", parish, adminCounty = "admin_county"
        case dateOfIntroduction = "date_of_introduction", adminWard = "admin_ward", ced, ccg, nuts, pfa, codes
    }
}

// Define the structure of the codes object
struct PostcodeCodes: Codable {
    let adminDistrict: String
    let adminCounty: String
    let adminWard: String
    let parish: String
    let parliamentaryConstituency: String
    let parliamentaryConstituency2024: String
    let ccg: String
    let ccgId: String
    let ced: String
    let nuts: String
    let lsoa: String
    let msoa: String
    let lau2: String
    let pfa: String

    enum CodingKeys: String, CodingKey {
        case adminDistrict = "admin_district", adminCounty = "admin_county", adminWard = "admin_ward"
        case parish, parliamentaryConstituency = "parliamentary_constituency"
        case parliamentaryConstituency2024 = "parliamentary_constituency_2024"
        case ccg, ccgId = "ccg_id", ced, nuts, lsoa, msoa, lau2, pfa
    }
}

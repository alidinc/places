//
//  PlaceType.swift
//  Places
//
//  Created by alidinc on 13/12/2024.
//

import Foundation

enum AddressType: String, Codable, CaseIterable {

    case residential = "Residential"
    case place = "Places"

    var icon: String {
        switch self {
        case .residential:
            return "house.fill"
        case .place:
            return "mappin.and.ellipse"
        }
    }
}

//
//  BuildingType.swift
//  Places
//
//  Created by alidinc on 13/12/2024.
//

import Foundation

enum BuildingType: String, Codable, CaseIterable {
    case flat = "Flat"
    case house = "House"
    case place = "Place"
    
    var iconName: String {
        switch self {
        case .house: return "house.fill"
        case .flat: return "building.fill"
        case .place: return "mappin.and.ellipse"
        }
    }
}

//
//  AppIcon.swift
//  Steps
//
//  Created by Ali Dinç on 14/08/2024.
//

import Foundation

enum AppIcon: Int, Identifiable, CaseIterable {

    case black = 0
    case red
    case green
    case blue
    case purple
    case white
    case darkRed
    case darkGreen
    case darkBlue
    case darkIndigo

    var id: Self { return self }

    var assetName: String {
        switch self {
        case .black:
            return "Icon"
        default:
            return "Icon\(self.rawValue)"
        }
    }

    var iconName: String {
        switch self {
        case .black:
            return "AppIcon"
        default:
            return "AppIcon\(self.rawValue)"
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .black:
            return "White"
        case .red:
            return "Dark Red"
        case .green:
            return "Dark Green"
        case .blue:
            return "Dark Blue"
        case .purple:
            return "Dark Indigo"
        case .white:
            return "Black"
        case .darkRed:
            return  "Red"
        case .darkGreen:
            return  "Green"
        case .darkBlue:
            return  "Blue"
        case .darkIndigo:
            return "Purple"
        }
    }
}

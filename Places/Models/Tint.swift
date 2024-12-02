//
//  Tint.swift
//  Forecasts
//
//  Created by Ali Dinç on 20/08/2024.
//

import SwiftUI

enum Tint: Int, CaseIterable, Hashable, Identifiable {

    var id: Self { return self }

    case black
    case green
    case cyan
    case brown
    case orange
    case pink
    case red
    case purple
    case indigo
    case blue

    var title: LocalizedStringResource {
        switch self {
        case .black:
            return "Primary"
        case .green:
            return "Green"
        case .cyan:
            return "Cyan"
        case .brown:
            return "Brown"
        case .orange:
            return "Orange"
        case .pink:
            return "Pink"
        case .red:
            return "Red"
        case .purple:
            return "Purple"
        case .indigo:
            return "Indigo"
        case .blue:
            return "Blue"
        }
    }

    var color: Color {
        switch self {
        case .green:
            return .green
        case .cyan:
            return .cyan
        case .brown:
            return .brown
        case .orange:
            return .orange
        case .pink:
            return .pink
        case .red:
            return .red
        case .purple:
            return .purple
        case .indigo:
            return .indigo
        case .blue:
            return .blue
        case .black:
            return Color.primary
        }
    }

    var displayColor: Color {
        switch self {
        case .green:
            return .green
        case .cyan:
            return .cyan
        case .brown:
            return .brown
        case .orange:
            return .orange
        case .pink:
            return .pink
        case .red:
            return .red
        case .purple:
            return .purple
        case .indigo:
            return .indigo
        case .blue:
            return .blue
        case .black:
            return .black
        }
    }
}

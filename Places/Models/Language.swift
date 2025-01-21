//
//  Language.swift
//  Places
//
//  Created by alidinc on 16/01/2025.
//

import Foundation

enum Language: String, CaseIterable, Identifiable {

    case english = "en"
    case turkey = "tr"

    var id: Self { return self }

    var title: LocalizedStringResource {
        switch self {
        case .turkey:
            return "Turkish"
        case .english:
            return "English"
        }
    }

    var flag: String {
        switch self {
        case .turkey:
            return "🇹🇷"
        case .english:
            return "🇬🇧"
        }
    }

    var key: String {
        switch self {
        case .turkey:
            return "tr"
        case .english:
            return "en"
        }
    }
}

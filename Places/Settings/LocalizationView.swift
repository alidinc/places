//
//  LocalizationView.swift
//  Tasks
//
//  Created by Ali Dinç on 20/07/2024.
//

import SwiftUI
import Observation

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


@Observable
class LanguageManager {

   private let defaults = UserDefaults.shared
   private let selectedLocalKey = "language"

    var language: Language {
        get {
            access(keyPath: \.language)
            return Language(rawValue: defaults.string(forKey: selectedLocalKey) ?? "en") ?? .english
        }

        set {
            withMutation(keyPath: \.language) {
                defaults.set(newValue.rawValue, forKey: selectedLocalKey)
            }
        }
    }
}

struct LocalizationView: View {

    @Bindable var settings: LanguageManager
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        NavigationLink(destination: LanguageSelectionView(selectedLanguage: $settings.language)) {
            SettingsRowView(icon: "globe", title: "Language") {
                Text("\(settings.language.flag) \(settings.language.title)")
            }
        }
    }
}

struct LanguageSelectionView: View {

    @Binding var selectedLanguage: Language
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            ForEach(Language.allCases) { language in
                Button {
                    selectedLanguage = language
                } label: {
                    Text("\(language.flag) \(language.title)")
                }
                .tag(language)
            }
        }
        .navigationTitle("Select Language")
    }
}

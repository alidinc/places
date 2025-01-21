//
//  LanguageManager.swift
//  Places
//
//  Created by alidinc on 16/01/2025.
//

import SwiftUI

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

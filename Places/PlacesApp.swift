//
//  PlacesApp.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import SwiftUI

@main
struct PlacesApp: App {

    var countriesVm = CountryViewModel()
    var language = LanguageManager()

    var body: some Scene {
        WindowGroup {
            ContentView(language: language)
                .tint(.primary)
                .environment(countriesVm)
                .environment(\.locale, .init(identifier: language.language.key))
                .modelContainer(for: Address.self)
        }
    }
}

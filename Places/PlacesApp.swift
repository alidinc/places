//
//  PlacesApp.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import SwiftUI

@main
struct PlacesApp: App {

    var vm = PlacesViewModel()
    var countriesVm = CountryViewModel()
    var language = LanguageManager()

    var body: some Scene {
        WindowGroup {
            ContentView(vm: vm, language: language)
                .tint(.primary)
                .environment(vm)
                .environment(countriesVm)
                .environment(\.locale, .init(identifier: language.language.key))
                .modelContainer(for: Place.self)
        }
    }
}

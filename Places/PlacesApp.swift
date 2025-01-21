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
    var contacts = ContactsManager()
    @State var hudState = HUDState()
    var locationsManager = LocationsManager()
    
    init() {
        locationsManager.requestAuthorisation()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(language: language)
                .tint(.primary)
                .environment(countriesVm)
                .environment(contacts)
                .environment(language)
                .environment(locationsManager)
                .environment(hudState)
                .fontDesign(.rounded)
                .environment(\.locale, .init(identifier: language.language.key))
                .hud(isPresented: $hudState.isPresented) {
                    HStack {
                        Image(systemName: hudState.systemImage)
                        Text(hudState.title)
                    }
                    .font(.subheadline.weight(.semibold))
                    .fontDesign(.rounded)
                }
                .modelContainer(for: [Address.self, ChecklistItem.self])
        }
    }
}

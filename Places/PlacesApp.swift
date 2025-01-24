//
//  PlacesApp.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import SwiftUI

@main
struct PlacesApp: App {
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false
    @State private var hudState = HUDState()

    var countriesVm = CountryViewModel()
    var language = LanguageManager()
    var contacts = ContactsManager()
    var locations = LocationsManager()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView(language: language)
                        .tint(.primary)
                        .environment(countriesVm)
                        .environment(contacts)
                        .environment(language)
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
                } else {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                        .transition(.move(edge: .trailing))
                }
            }
            .environment(locations)
        }
    }
}

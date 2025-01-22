//
//  OnboardingPage.swift
//  Places
//
//  Created by alidinc on 22/01/2024.
//

import Foundation

enum OnboardingPageType {
    case features
    case location
    case tint
    case getStarted
}

struct OnboardingPage: Identifiable {
    
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
    let type: OnboardingPageType
    
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to Places",
            subtitle: "Your personal address book for keeping track of all your locations",
            imageName: "map.fill",
            type: .features
        ),
        OnboardingPage(
            title: "Enable Location",
            subtitle: "Allow Places to access your location to help you find and navigate to addresses easily.",
            imageName: "location.fill",
            type: .location
        ),
        OnboardingPage(
            title: "Personalize Your App",
            subtitle: "Choose a color theme that suits your style and makes Places uniquely yours.",
            imageName: "paintpalette.fill",
            type: .tint
        ),
        OnboardingPage(
            title: "Ready to Start?",
            subtitle: "Begin organising your addresses and making the most of Places.",
            imageName: "checkmark.circle.fill",
            type: .getStarted
        )
    ]

}

struct Feature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    
    static let features = [
        Feature(
            icon: "map.fill",
            title: "Track Your Places",
            subtitle: "Keep track of all your addresses, past and present, in one organised place"
        ),
        Feature(
            icon: "folder.fill",
            title: "Smart Organization",
            subtitle: "Manage documents, checklists, and important notes for each address"
        ),
        Feature(
            icon: "person.2.fill",
            title: "Stay Connected",
            subtitle: "Keep track of friends' addresses and stay connected with loved ones"
        )
    ]
    
    static let location = [
        Feature(
                    icon: "location.fill",
                    title: "Find Addresses",
                    subtitle: "Easily locate and navigate to any saved address with precise location tracking"
                ),
                Feature(
                    icon: "arrow.triangle.turn.up.right.diamond.fill",
                    title: "Get Directions",
                    subtitle: "Access instant turn-by-turn navigation and routing to reach any of your saved addresses"
                ),
                Feature(
                    icon: "map.fill",
                    title: "View on Map",
                    subtitle: "Explore all your saved addresses on an interactive map with detailed location"
                )

    ]
}

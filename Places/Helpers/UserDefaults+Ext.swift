//
//  UserDefaults+Ext.swift
//  Steps
//
//  Created by alidinc on 30/10/2024.
//

import Foundation

extension UserDefaults {

    static let shared = UserDefaults(suiteName: "group.com.alidinc.places")!

    enum Key: String {
        case hasSeenOnboarding
    }

    var hasSeenOnboarding: Bool {
        get { bool(forKey: Key.hasSeenOnboarding.rawValue) }
        set { setValue(newValue, forKey: Key.hasSeenOnboarding.rawValue) }
    }
}

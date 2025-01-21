//
//  Constants.swift
//  Forecasts
//
//  Created by Ali Dinç on 20/08/2024.
//

import Foundation
import UIKit

enum Constants {

    struct Text {
        static let PurchaseTitle: LocalizedStringResource = "Thank You 💕"
        static let PurchaseMessage: LocalizedStringResource = "Much appreciate your support. Please let me know, if you have any feedback."
    }

    struct Notifications {
        static let addressesChanged = Notification.Name("addressesChanged")
        static let editingAddress = Notification.Name("editingAddress")
        static let deletedAddress = Notification.Name("deletedAddress")
    }

    struct URLs {
        static let SwiftUI = "https://developer.apple.com/documentation/swiftui/"
        static let WeatherKit = "https://developer.apple.com/weatherkit/data-source-attribution/"
        static let AppStoreURL = "https://apps.apple.com/us/app/forecasts-minimalist-weather/id6651821166"
        static let ThreadsURL = "https://www.threads.net/@alidinc._"
        static func LinkedIn(profile: String) -> String {
            let webURLString = "https://www.linkedin.com/in/\(profile)"
            let appURLString = "linkedin://profile/\(profile)"

            if let appURL = URL(string: appURLString), UIApplication.shared.canOpenURL(appURL) {
                return appURLString
            } else if let webURL = URL(string: webURLString), UIApplication.shared.canOpenURL(webURL) {
                return webURLString
            } else {
                return webURLString
            }
        }
    }
}

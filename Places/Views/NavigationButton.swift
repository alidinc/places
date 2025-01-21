//
//  ActionsButton.swift
//  Places
//
//  Created by alidinc on 15/01/2025.
//

import SwiftUI

struct NavigationButton: View {
    
    var address: Address
    
    var body: some View {
        Menu {
            Text("Navigate")
            
            Button(action: openInAppleMaps) {
                Label("Open in Apple Maps", systemImage: "map.fill")
            }
            
            Button(action: openInGoogleMaps) {
                Label("Open in Google Maps", systemImage: "globe")
            }
            
            Divider()
        } label: {
            Image(systemName: "map.fill")
        }
        .tint(.blue)
    }
    
    private func openInAppleMaps() {
        if let url = URL(string: "maps://?address=\(address.encodedAddress)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openInGoogleMaps() {
        let googleMapsUrl = "comgooglemaps://?q=\(address.encodedAddress)"
        let googleMapsWebUrl = "https://www.google.com/maps/search/?api=1&query=\(address.encodedAddress)"
        
        if let url = URL(string: googleMapsUrl), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let webUrl = URL(string: googleMapsWebUrl) {
            UIApplication.shared.open(webUrl)
        }
    }
}


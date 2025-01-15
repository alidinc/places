//
//  ActionsButton.swift
//  Places
//
//  Created by alidinc on 15/01/2025.
//

import SwiftUI
import UIKit

struct ActionsButton: View {
    
    var address: Address
    @Binding var showingCopyAlert: Bool
    
    var body: some View {
        Menu {
            HStack(spacing: 16) {
                Menu {
                    Button(action: openInAppleMaps) {
                        Label("Open in Apple Maps", systemImage: "map.fill")
                    }
                    
                    Button(action: openInGoogleMaps) {
                        Label("Open in Google Maps", systemImage: "globe")
                    }
                } label: {
                    Label("Navigate", systemImage: "map.fill")
                }
                
                Button(action: copyToClipboard) {
                    Label("Copy to Clipboard", systemImage: "document.on.clipboard.fill")
                }
                
                ShareLink(item: address.fullAddress) {
                    Label("Share", systemImage: "square.and.arrow.up.fill")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: .capsule)
        } label: {
            Image(systemName: "ellipsis.circle.fill")
        }
        .foregroundStyle(.secondary)
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = address.fullAddress
        showingCopyAlert = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    private func openInAppleMaps() {
        let address = [address.addressLine1, address.addressLine2, address.city, address.postcode, address.country]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
        
        let addressEncoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "maps://?address=\(addressEncoded)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openInGoogleMaps() {
        let address = [address.addressLine1, address.addressLine2, address.city, address.postcode, address.country]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
        
        let addressEncoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let googleMapsUrl = "comgooglemaps://?q=\(addressEncoded)"
        let googleMapsWebUrl = "https://www.google.com/maps/search/?api=1&query=\(addressEncoded)"
        
        if let url = URL(string: googleMapsUrl), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let webUrl = URL(string: googleMapsWebUrl) {
            UIApplication.shared.open(webUrl)
        }
    }
}


//
//  PlaceRow.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import SwiftUI
import UIKit

struct AddressRow: View {

    var place: Address

    @AppStorage("tint") private var tint: Tint = .blue
    @Environment(\.modelContext) private var modelContext
    @State private var showingCopyAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            addressButton
            durationInfo
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.clear)
        .alert("Copied", isPresented: $showingCopyAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Address copied to clipboard")
        }
    }

    private var addressButton: some View {
        Button {
            copyToClipboard()
        } label: {
            Text(place.fullAddress)
                .font(.subheadline.weight(.medium))
        }
    }

    private var durationInfo: some View {
        Group {
            HStack {
                dateRangeText
                Spacer()
                
                HStack {
                    Text(place.durationString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Image(systemName: place.buildingType.iconName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var dateRangeText: some View {
        Group {
            if let startDate = place.startDate {
                if let startDate = place.startDate, place.isCurrent {
                    Text("\(startDate.formatted(.dateTime.day().month().year())) • Present")
                        .foregroundStyle(tint.color)
                } else if let endDate = place.endDate {
                    Text("\(startDate.formatted(.dateTime.day().month().year())) • \(endDate.formatted(.dateTime.day().month().year()))")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .font(.caption.weight(.medium))
    }

    private func copyToClipboard() {
        UIPasteboard.general.string = place.fullAddress
        showingCopyAlert = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

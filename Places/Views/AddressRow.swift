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
        VStack(alignment: .leading, spacing: 8) {
            AddressLineView
            DurationView
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .alert(isPresented: $showingCopyAlert) {
            Alert(title: Text("Copied"),
                  message: Text("Address copied to clipboard"),
                  dismissButton: .default(Text("OK")))
        }
    }

    private var AddressLineView: some View {
        Button {
            UIPasteboard.general.string = place.fullAddress
            showingCopyAlert = true
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } label: {
            Text(place.fullAddress)
                .font(.subheadline.weight(.medium))
        }
    }

    @ViewBuilder
    private var DurationView: some View {
        if let startDate = place.startDate {
            HStack {
                Group {
                    if let endDate = place.endDate {
                        Text("\(startDate.formatted(.dateTime.day().month().year())) • \(endDate.formatted(.dateTime.day().month().year()))")
                    } else {
                        HStack {
                            Circle().fill(.green).frame(width: 6, height: 6)
                            Text("\(startDate.formatted(.dateTime.day().month().year())) • Present")
                        }
                    }
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(tint.color.opacity(0.85))
                
                Spacer()

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

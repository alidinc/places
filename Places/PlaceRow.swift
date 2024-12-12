//
//  PlaceRow.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import SwiftUI
import UIKit

struct PlaceRow: View {

    var place: Place

    @AppStorage("tint") private var tint: Tint = .blue
    @Environment(\.modelContext) private var modelContext
    @State private var showingCopyAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AddressLineView
            DurationView
        }
        .padding(14)
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
                .font(.headline)
        }
    }

    @ViewBuilder
    private var DurationView: some View {
        if let startDate = place.startDate {
            VStack(alignment: .leading) {
                if let endDate = place.endDate {
                    Text("\(startDate.formatted(.dateTime.day().month().year())) • \(endDate.formatted(.dateTime.day().month().year()))")
                        .font(.subheadline)
                        .foregroundStyle(tint.color.opacity(0.85))
                } else {
                    // No end date, show "Now"
                    HStack {
                        Circle().fill(.green).frame(width: 6, height: 6)
                        Text("\(startDate.formatted(.dateTime.day().month().year())) • Present")
                            .font(.subheadline)
                            .foregroundStyle(tint.color.opacity(0.85))
                    }
                }

                Text(place.durationString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

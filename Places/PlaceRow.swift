//
//  PlaceRow.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//


import SwiftUI
import UIKit

struct PlaceRow: View {

    @AppStorage("tint") private var tint: Tint = .blue
    @Environment(\.modelContext) private var modelContext
    @State var address: Place
    @State private var showingCopyAlert = false

    var body: some View {
        VStack(alignment: .leading) {
            AddressLineView

            HStack {
                PlaceTypePicker
                Spacer()
                ClipboardButton
            }

            DurationView
        }
        .alert(isPresented: $showingCopyAlert) {
            Alert(title: Text("Copied"), message: Text("Address copied to clipboard"), dismissButton: .default(Text("OK")))
        }
    }

    private var AddressLineView: some View {
        if address.placeType == .placeToVisit {
            Text(address.addressLine)
                .font(.headline)
        } else {
            if address.apartmentNumber.isEmpty {
                Text(address.addressLine)
                    .font(.headline)
            } else {
                Text("\(address.apartmentNumber), \(address.addressLine)")
                    .font(.headline)
            }
        }
    }

    private var PlaceTypePicker: some View {
        Menu {
            ForEach(PlaceType.allCases, id: \.self) { type in
                Button {
                    address.placeType = type
                    try? modelContext.save()
                } label: {
                    Text(type.rawValue)
                }
            }
        } label: {
            HStack {
                Image(systemName: address.placeType.icon)
                    .foregroundStyle(tint.color.gradient)
                Text(address.placeType.rawValue)
                    .foregroundStyle(.secondary)
            }
            .capsule()
        }
    }

    @ViewBuilder
    private var DurationView: some View {
        if address.placeType == .residentialTenancy, let startDate = address.startDate {
            if let endDate = address.endDate {
                // Display the date range
                Text("\(startDate, format: .dateTime.day().month().year()) - \(endDate.formatted(.dateTime.day().month().year()))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                // No end date, show "Now"
                Text("\(startDate, format: .dateTime.day().month().year()) - Now")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Display duration string (assuming it handles nil end date gracefully)
            Text(address.durationString)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var ClipboardButton: some View {
        Button(action: {
            UIPasteboard.general.string = "\(address.apartmentNumber), \(address.addressLine)"
            showingCopyAlert = true

            // Optional: Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }) {
            Image(systemName: "doc.on.doc")
                .foregroundColor(.blue)
                .accessibilityLabel("Copy address to clipboard")
        }
        .buttonStyle(.plain)
    }
}

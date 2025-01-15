//
//  PlaceRow.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import SwiftUI
import UIKit
import MapKit

struct AddressRow: View {
    
    var place: Address
    
    @AppStorage("tint") private var tint: Tint = .blue
    @Environment(\.modelContext) private var modelContext
    @State private var showingCopyAlert = false
    
    var body: some View {
        VStack(alignment: .leading) {
            AddressLineView
            durationInfo
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.clear)
        .alert("Address copied to clipboard", isPresented: $showingCopyAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
    private var AddressLineView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(place.mainAddressDetails)
                .font(.headline.weight(.medium))
            Text(place.localityDetails)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }
    
    private var durationInfo: some View {
        Group {
            HStack {
                dateRangeText
                Spacer()
                
                HStack {
                    Image(systemName: place.buildingType.iconName)
                    Text(place.durationString)
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                ActionsButton(address: place, showingCopyAlert: $showingCopyAlert)
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
}

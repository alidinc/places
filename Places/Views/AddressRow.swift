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
    
    @AppStorage("current") private var currentAddressId = ""
    @AppStorage("tint") private var tint: Tint = .blue
    
    var place: Address
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            addressLineView
            bottomInfo
        }
        .padding(.vertical, 16)
        .padding(.leading)
        .padding(.trailing, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.clear)
    }
    
    private var addressLineView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(place.mainAddressDetails)
            Text(place.localityDetails)
        }
        .font(.headline.weight(.medium))
    }
    
    @ViewBuilder
    private var bottomInfo: some View {
        switch place.addressOwner {
        case .mine:
            HStack {
                Group {
                    if let startDate = place.startDate {
                        if let startDate = place.startDate, place.id == currentAddressId {
                            Text("\(startDate.formatted(.dateTime.day().month().year())) • Present")
                                .foregroundStyle(tint.color)
                        } else if let endDate = place.endDate {
                            Text("\(startDate.formatted(.dateTime.day().month().year())) • \(endDate.formatted(.dateTime.day().month().year()))")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .font(.caption.weight(.medium))
                
                Spacer()
                
                Text(place.durationString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        case .friend:
            if !place.ownerName.isEmpty {
                HStack {
                    Text(place.ownerName)
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(tint.color.opacity(0.5), in: .capsule)
                    
                    if let relationship = place.relationship, !relationship.isEmpty {
                        Text(relationship)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(tint.color.opacity(0.5), in: .capsule)
                    }
                }
            }
        }
    }
}

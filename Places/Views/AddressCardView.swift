//
//  AddressCardView.swift
//  Places
//
//  Created by alidinc on 21/12/2024.
//

import SwiftUI

struct AddressCardView: View {
    @AppStorage("tint") private var tint: Tint = .blue
    let place: Address
    @Binding var showAddressDetails: Bool
    
    var body: some View {
        Section("Address Details") {
            VStack(alignment: .leading, spacing: 12) {
                // Address Info
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        if !place.apartmentNumber.isEmpty {
                            Text("\(place.buildingType == .flat ? "Flat " : "")\(place.apartmentNumber)")
                                .font(.subheadline.weight(.medium))
                        }
                        
                        Text(place.addressLine1)
                            .font(.subheadline.weight(.medium))
                        
                        if !place.addressLine2.isEmpty {
                            Text(place.addressLine2)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if !place.country.unicodeFlag.isEmpty {
                        Text(place.country.unicodeFlag)
                            .font(.title2)
                    }
                }
                
                // Location Info
                HStack {
                    VStack(alignment: .leading) {
                        Text(place.city)
                            .font(.subheadline.weight(.medium))
                        Text(place.postcode)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        showAddressDetails = true
                    } label: {
                        Text("Edit")
                    }
                    .buttonStyle(.plain)
                    .contentShape(.rect)
                    .capsuleButtonStyle()
                }
            }
            .padding(.vertical, 8)
        }
        .listRowBackground(StyleManager.shared.listRowBackground)
        .listRowSeparatorTint(StyleManager.shared.listRowSeparator)
    }
}


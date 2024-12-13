//
//  HeaderView.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import SwiftData
import SwiftUI

struct HeaderView: View {

    @AppStorage("tint") private var tint: Tint = .blue
    @Query private var savedAddresses: [Address]
    @State var placeType: AddressType = .residential

    var oldestDate: Date {
        savedAddresses.compactMap({ $0.startDate }).min() ?? .now
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(savedAddresses.count, format: .number)
                .font(.system(size: 80).weight(.semibold))
                .contentTransition(.numericText())

            PlaceTypePicker

            Text("Since \(oldestDate, format: .dateTime.day().month().year())")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(height: UIScreen.main.bounds.height / 4.5)
    }

    private var PlaceTypePicker: some View {
        Menu {
            ForEach(AddressType.allCases, id: \.self) { type in
                Button {
                    self.placeType = type
                } label: {
                    Text(type.rawValue)
                }
            }
        } label: {
            HStack(alignment: .lastTextBaseline) {
                Image(systemName: placeType.icon)
                Text(placeType.rawValue)
            }
            .foregroundStyle(tint.color.gradient)
            .font(.subheadline.weight(.medium))
            .capsule()
        }
    }
}

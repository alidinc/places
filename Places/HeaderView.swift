//
//  HeaderView.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import SwiftData
import SwiftUI

struct HeaderView: View {

    @Query private var savedAddresses: [Place]
    @State var placeType: PlaceType = .residential

    var body: some View {
        VStack(spacing: 12) {
            Text(savedAddresses.count, format: .number)
                .font(.system(size: 80).weight(.semibold))
                .contentTransition(.numericText())

            PlaceTypePicker
        }
        .frame(height: UIScreen.main.bounds.height / 4.5)
    }

    private var PlaceTypePicker: some View {
        Menu {
            ForEach(PlaceType.allCases, id: \.self) { type in
                Button {
                    self.placeType = type
                } label: {
                    Text(type.rawValue)
                }
            }
        } label: {
            HStack {
                Image(systemName: placeType.icon)
                Text(placeType.rawValue)
            }
            .foregroundStyle(.secondary)
            .font(.headline.weight(.medium))
        }
    }
}
